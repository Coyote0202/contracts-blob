use core::{
    hash::{HashStateTrait, HashStateExTrait}, poseidon::{PoseidonTrait, HashState},
    {integer::u128_safe_divmod, cmp::min}
};

// use alexandria_data_structures::array_ext::SpanTraitExt;
// use alexandria_data_structures::array_ext::ArrayTraitExt;
use cubit::f128::types::fixed::{FixedTrait, Fixed, HALF};


use blob_arena::{
    core::{SaturatingInto, SaturatingSub}, utils::{UpdateHashToU128},
    components::{
        combat::Phase,
        combatant::{
            CombatantState, CombatantStats, CombatantInfo, CombatantTrait, CombatantStatsTrait,
            CombatantStateTrait
        },
        attack::{Attack, AttackTrait, AvailableAttack}, utils::{AB, ABT, ABTTrait}, stats::{Stats},
    },
    models::{
        Effect, Affect, Damage, Target, Stat, AttackOutcomes, EffectResult, AffectResult,
        DamageResult, AttackResult
    },
};
use dojo::{world::{IWorldDispatcher, IWorldDispatcherTrait}, model::Model};


const THREE_TENTHS_FIXED: Fixed = Fixed { mag: 5534023222112865484, sign: false };
const HUNDRED_FIXED: Fixed = Fixed { mag: 1844674407370955161600, sign: false };
const FIXED_255: Fixed = Fixed { mag: 4703919738795935662080, sign: false };
const HUNDREDTH_FIXED: Fixed = Fixed { mag: 184467440737095516, sign: false };
const NZ_255: NonZero<u128> = 255;
const NZ_100: NonZero<u128> = 100;

#[derive(Drop, Serde)]
struct PlannedAttack {
    combatant: felt252,
    attack: Attack,
    target: felt252,
}

fn apply_luck_modifier<T, +TryInto<Fixed, T>, +Into<u8, T>, +Zeroable<T>>(
    value: u8, luck: u8
) -> T {
    if value == 0 {
        return Zeroable::zero();
    };
    let luck_ratio: Fixed = (300_u16 - luck.into()).into() / (200_u16 + luck.into()).into();
    let value_float = value.into() / HUNDRED_FIXED;
    let new_value = (value_float.pow(luck_ratio) * FIXED_255);
    if new_value > FIXED_255 {
        255_u8.into()
    } else {
        new_value.try_into().unwrap()
    }
}

fn get_new_stun_chance(current_stun: u8, attack_stun: u8, luck: u8) -> u8 {
    let stun_chance = apply_luck_modifier(attack_stun, luck);
    (current_stun.into() + stun_chance - (current_stun.into() * stun_chance / 255_u16))
        .saturating_into()
}

// power * (1 + 0.004 * strength)
fn damage_calculation(move_power: u8, strength: u8, critical: bool) -> u8 {
    (move_power.into() * (100 + strength.into()) / if critical {
        125_u128
    } else {
        250_u128
    })
        .saturating_into()
}

trait SeedProbability<T> {
    fn get_outcome(ref self: u128, scale: NonZero<u128>, probability: T) -> bool;
}

impl SeedProbabilityImpl<T, +Into<T, u128>,> of SeedProbability<T> {
    fn get_outcome(ref self: u128, scale: NonZero<u128>, probability: T) -> bool {
        let (seed, value) = u128_safe_divmod(self, scale);
        self = seed;
        value < probability.into()
    }
}

fn did_hit(accuracy: u8, seed: u128) -> (u128, bool) {
    let (seed, value) = u128_safe_divmod(seed, NZ_100);
    (seed, value < accuracy.into())
}

fn did_critical(chance: u8, luck: u8, seed: u128) -> (u128, bool) {
    let critical: u8 = apply_luck_modifier(chance, luck);
    let (seed, value) = u128_safe_divmod(seed, NZ_255);
    (seed, value < critical.into())
}

fn is_stunned(stun_chance: u8, seed: u128) -> (u128, bool) {
    let (seed, value) = u128_safe_divmod(seed, NZ_255);
    (seed, value < stun_chance.into())
}

#[generate_trait]
impl AttackerImpl of AttackerTrait {
    fn run_stun(ref self: CombatantState, ref seed: u128) -> bool {
        let stunned = seed.get_outcome(NZ_255, self.stun_chance);
        self.stun_chance = 0;
        stunned
    }
}

fn effect_health(ref self: CombatantState, stats: CombatantStats, health: i16) {
    let max_health = stats.get_max_health(self).into();
    let mut new_health = self.health.into() + health;
    if new_health > max_health {
        new_health = max_health
    }
    self.health = new_health.saturating_into();
}

fn apply_stun(ref self: CombatantState, luck: u8, stun: u8) {
    self.stun_chance = get_new_stun_chance(self.stun_chance, stun, luck)
}


fn run_effect(
    attacker_stats: CombatantStats,
    defender_stats: CombatantStats,
    ref attacker_state: CombatantState,
    ref defender_state: CombatantState,
    effect: Effect,
    hash_state: HashState,
) -> (EffectResult, HashState) {
    let result = match effect.affect {
        Affect::Stats(stats_effect) => {
            match effect.target {
                Target::Player => { attacker_state.apply_buffs(attacker_stats, stats_effect) },
                Target::Opponent => { defender_state.apply_buffs(defender_stats, stats_effect) },
            };
            AffectResult::Success
        },
        Affect::Stat(Stat { stat,
        amount }) => {
            match effect.target {
                Target::Player => { attacker_state.apply_buff(attacker_stats, stat, amount) },
                Target::Opponent => { defender_state.apply_buff(defender_stats, stat, amount) },
            };
            AffectResult::Success
        },
        Affect::Damage(damage) => {
            let seed = hash_state.update_to_u128('salt');
            let (_seed, critical) = did_critical(
                damage.critical, attacker_stats.get_luck(attacker_state), seed
            );

            let damage = damage_calculation(
                damage.power, attacker_stats.get_strength(attacker_state), critical
            );
            match effect.target {
                Target::Player => { attacker_state.health -= min(attacker_state.health, damage) },
                Target::Opponent => { defender_state.health -= min(defender_state.health, damage) },
            };
            AffectResult::Damage(DamageResult { critical, damage })
        },
        Affect::Stun(stun) => {
            match effect.target {
                Target::Player => {
                    apply_stun(ref attacker_state, attacker_stats.get_luck(attacker_state), stun)
                },
                Target::Opponent => {
                    apply_stun(ref attacker_state, attacker_stats.get_luck(attacker_state), stun)
                },
            };
            AffectResult::Success
        },
        Affect::Health(health) => {
            match effect.target {
                Target::Player => { attacker_state.modify_health(attacker_stats, health) },
                Target::Opponent => { defender_state.modify_health(defender_stats, health) },
            };
            AffectResult::Success
        },
    };
    (EffectResult { target: effect.target, affect: result, }, hash_state)
}

fn run_effects(
    attacker_stats: CombatantStats,
    defender_stats: CombatantStats,
    ref attacker_state: CombatantState,
    ref defender_state: CombatantState,
    mut effects: Array<Effect>,
    mut hash_state: HashState,
) -> Array<EffectResult> {
    let mut results: Array<EffectResult> = ArrayTrait::new();
    loop {
        match effects.pop_front() {
            Option::Some(effect) => {
                let (result, _hash_state) = run_effect(
                    attacker_stats,
                    defender_stats,
                    ref attacker_state,
                    ref defender_state,
                    effect,
                    hash_state,
                );
                hash_state = _hash_state;
                results.append(result);
            },
            Option::None => { break; },
        }
    };
    results
}

#[generate_trait]
impl CombatWorldImp of CombatWorldTraits {
    fn run_attack_check(
        self: IWorldDispatcher, combatant_id: felt252, attack_id: felt252, cooldown: u8, round: u32
    ) -> bool {
        let attack_available = self.get_available_attack(combatant_id, attack_id);
        if !attack_available.available {
            false
        } else {
            if cooldown == 0 {
                return true;
            }
            let last_used = attack_available.last_used;
            if last_used.is_non_zero() && (cooldown.into() + last_used) > round {
                return false;
            };
            self.set_available_attack(combatant_id, attack_id, round);
            true
        }
    }

    fn run_attack(
        self: IWorldDispatcher,
        attacker_stats: CombatantStats,
        defender_stats: CombatantStats,
        ref attacker_state: CombatantState,
        ref defender_state: CombatantState,
        attack: Attack,
        round: u32,
        hash_state: HashState
    ) {
        let hash_state = hash_state.update_with(attacker_stats.id);
        let mut seed = hash_state.to_u128();
        let result = if !self
            .run_attack_check(attacker_stats.id, attack.id, attack.cooldown, round) {
            AttackOutcomes::Failed
        } else if attacker_state.run_stun(ref seed) {
            AttackOutcomes::Stunned
        } else if seed.get_outcome(NZ_100, attack.accuracy) {
            AttackOutcomes::Hit(
                run_effects(
                    attacker_stats,
                    defender_stats,
                    ref attacker_state,
                    ref defender_state,
                    attack.hit,
                    hash_state
                )
            )
        } else {
            AttackOutcomes::Miss(
                run_effects(
                    attacker_stats,
                    defender_stats,
                    ref attacker_state,
                    ref defender_state,
                    attack.miss,
                    hash_state
                )
            )
        };
        emit!(
            self,
            AttackResult {
                combatant_id: attacker_stats.id, round, target: defender_stats.id, result
            }
        )
    }
}

