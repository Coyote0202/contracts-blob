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
        combat::{Phase, AffectResult, DamageResult},
        combatant::{CombatantState, CombatantInfo, CombatantTrait, CombatantStateTrait},
        attack::{Attack, AttackTrait, AvailableAttack}, utils::{AB, ABT, ABTTrait}, stats::{Stats},
    },
    models::{
        Effect, Affect, Damage, Target, Stat, AttackOutcomes, DamageResultEvent, AttackResult,
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

fn get_new_stun_chance(current_stun: u8, attack_stun: u8) -> u8 {
    (current_stun.into()
        + attack_stun.into()
        - (current_stun.into() * attack_stun.into() / 100_u16))
        .saturating_into()
}

// power * (1 + 0.004 * strength)
fn damage_calculation(move_power: u8, strength: u8, critical: bool) -> u8 {
    (move_power.into() * (100 + strength.into()) / if critical {
        100_u128
    } else {
        200_u128
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

fn did_critical(chance: u8, luck: u8, seed: u128) -> (u128, bool) {
    let critical: u8 = apply_luck_modifier(chance, luck);
    let (seed, value) = u128_safe_divmod(seed, NZ_255);
    (seed, value < critical.into())
}

#[generate_trait]
impl AttackerImpl of AttackerTrait {
    fn run_stun(ref self: CombatantState, ref seed: u128) -> bool {
        let stun_chance: u8 = apply_luck_modifier(self.stun_chance, 100 - self.stats.luck);
        self.stun_chance = 0;
        seed.get_outcome(NZ_255, stun_chance)
    }
}


fn apply_stun(ref self: CombatantState, stun: u8) {
    self.stun_chance = get_new_stun_chance(self.stun_chance, stun)
}


fn run_effect(
    ref attacker_state: CombatantState,
    ref defender_state: CombatantState,
    effect: @Effect,
    move_n: u8,
    hash_state: HashState,
) -> AffectResult {
    match effect.affect {
        Affect::Stats(stats_effect) => {
            match effect.target {
                Target::Player => { attacker_state.apply_buffs(stats_effect) },
                Target::Opponent => { defender_state.apply_buffs(stats_effect) },
            };
            AffectResult::Success
        },
        Affect::Stat(Stat { stat,
        amount }) => {
            match effect.target {
                Target::Player => { attacker_state.apply_buff(*stat, *amount) },
                Target::Opponent => { defender_state.apply_buff(*stat, *amount) },
            };
            AffectResult::Success
        },
        Affect::Damage(damage) => {
            let seed = hash_state.update_to_u128(move_n);
            let (_seed, critical) = did_critical(*damage.critical, attacker_state.stats.luck, seed);

            let damage = damage_calculation(*damage.power, attacker_state.stats.strength, critical);
            match effect.target {
                Target::Player => { attacker_state.modify_health::<i16>(-(damage.into())) },
                Target::Opponent => { defender_state.modify_health::<i16>(-(damage.into())) },
            };
            AffectResult::Damage(
                DamageResult { critical, damage, move: move_n, target: *effect.target }
            )
        },
        Affect::Stun(stun) => {
            match effect.target {
                Target::Player => { apply_stun(ref attacker_state, *stun) },
                Target::Opponent => { apply_stun(ref defender_state, *stun) },
            };
            AffectResult::Success
        },
        Affect::Health(health) => {
            match effect.target {
                Target::Player => { attacker_state.modify_health(*health) },
                Target::Opponent => { defender_state.modify_health(*health) },
            };
            AffectResult::Success
        },
    }
}

fn run_effects(
    ref attacker_state: CombatantState,
    ref defender_state: CombatantState,
    mut effects: Span<Effect>,
    hash_state: HashState,
) -> Span<AffectResult> {
    let mut results: Array<AffectResult> = ArrayTrait::new();
    let mut n = 0;
    loop {
        match effects.pop_front() {
            Option::Some(effect) => {
                results
                    .append(
                        run_effect(ref attacker_state, ref defender_state, effect, n, hash_state,)
                    );
                n += 1;
            },
            Option::None => { break; },
        }
    };
    results.span()
}


#[generate_trait]
impl CombatWorldImp of CombatWorldTraits {
    fn emit_attack_result(
        self: IWorldDispatcher,
        combatant_id: felt252,
        round: u32,
        target: felt252,
        result: AttackOutcomes,
        mut effects: Span<AffectResult>,
    ) {
        emit!(self, AttackResult { combatant_id, round, target, result });
        loop {
            match effects.pop_front() {
                Option::Some(effect) => {
                    match effect {
                        AffectResult::Damage(damage) => {
                            emit!(
                                self,
                                DamageResultEvent {
                                    combatant_id,
                                    round,
                                    move: *damage.move,
                                    target: *damage.target,
                                    damage: *damage.damage,
                                    critical: *damage.critical
                                }
                            );
                        },
                        AffectResult::Success => {},
                    }
                },
                Option::None => { break; },
            }
        }
    }
    fn get_attacker_attack_speed(
        self: @IWorldDispatcher, state: @CombatantState, attack: @Attack
    ) -> u8 {
        *state.stats.dexterity + *attack.speed
    }
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
        ref attacker_state: CombatantState,
        ref defender_state: CombatantState,
        attack: @Attack,
        round: u32,
        hash_state: HashState
    ) {
        let hash_state = hash_state.update_with(attacker_state.id);
        let mut seed = hash_state.to_u128();
        if !self.run_attack_check(attacker_state.id, *attack.id, *attack.cooldown, round) {
            self
                .emit_attack_result(
                    attacker_state.id, round, defender_state.id, AttackOutcomes::Failed, [].span()
                );
        } else if attacker_state.run_stun(ref seed) {
            self
                .emit_attack_result(
                    attacker_state.id, round, defender_state.id, AttackOutcomes::Stunned, [].span()
                );
        } else if seed.get_outcome(NZ_100, *attack.accuracy) {
            self
                .emit_attack_result(
                    attacker_state.id,
                    round,
                    defender_state.id,
                    AttackOutcomes::Hit,
                    run_effects(
                        ref attacker_state, ref defender_state, attack.hit.span(), hash_state
                    )
                );
        } else {
            self
                .emit_attack_result(
                    attacker_state.id,
                    round,
                    defender_state.id,
                    AttackOutcomes::Miss,
                    run_effects(
                        ref attacker_state, ref defender_state, attack.miss.span(), hash_state
                    )
                );
        };
    }
}

