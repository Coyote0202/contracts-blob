use core::{
    hash::HashStateTrait, poseidon::{PoseidonTrait, HashState},
    dict::{Felt252Dict, Felt252DictTrait}
};

// use alexandria_data_structures::array_ext::SpanTraitExt;
// use alexandria_data_structures::array_ext::ArrayTraitExt;
use cubit::f128::types::fixed::{FixedTrait, Fixed, HALF};

use alexandria_math::BitShift;
use blob_arena::{
    core::{LimitSub, LimitAdd},
    components::{
        combat::{Phase, AttackEffect, AttackHit},
        combatant::{CombatantState, CombatantStats, CombatantInfo, CombatantTrait},
        attack::{Attack, AttackTrait, AvailableAttack}, utils::{AB, ABT, ABTTrait}, stats::{Stats},
    },
    models::{AttackResult},
};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

const HUNDRED: felt252 = 1844674407370955161600;
const FIXED_255: u128 = 4703919738795935662080;
const HUNDREDTH: felt252 = 184467440737095516;
const THREE_TENTHS: felt252 = 5534023222112865484;


#[derive(Drop, Serde, Copy)]
struct PlannedAttack {
    combatant: u128,
    attack: Attack,
    target: u128,
}

fn apply_strength_modifier<T, +TryInto<Fixed, T>, +Into<u8, T>, +Zeroable<T>>(
    value: u8, strength: u8
) -> T {
    if value == 0 {
        return Zeroable::zero();
    };
    let strength_ratio: Fixed = (300_u16 - strength.into()).into()
        / (200_u16 + strength.into()).into();
    let value_float: Fixed = value.into() / FixedTrait::from_felt(HUNDRED);
    let new_value = (value_float.pow(strength_ratio) * Fixed { mag: FIXED_255, sign: false });
    if new_value.mag > FIXED_255 {
        255_u8.into()
    } else {
        new_value.try_into().unwrap()
    }
}

fn get_new_stun_chance(current_stun: u8, attack_stun: u8, strength: u8) -> u8 {
    let stun_chance = apply_strength_modifier(attack_stun, strength);
    let mut new_stun = current_stun.into()
        + stun_chance
        - (current_stun.into() * stun_chance / 255_u16);
    if new_stun > 255 {
        new_stun = 255;
    };
    new_stun.try_into().unwrap()
}

fn damage_calculation(attack: u8, damage: u8, critical: bool) -> u8 {
    if damage == 0 {
        return 0;
    };
    let mut calc_damage: u32 = ((damage.into() / FixedTrait::from_felt(HUNDRED))
        .pow(FixedTrait::from_felt(THREE_TENTHS))
        * (200_u8.into() + attack.into()))
        .try_into()
        .unwrap(); // max value 300
    calc_damage /= if critical {
        6
    } else {
        12
    };
    if calc_damage > 255 {
        calc_damage = 255;
    };
    calc_damage.try_into().unwrap()
}

#[generate_trait]
impl AttackerImpl of AttackerTrait {
    fn get_damage(self: CombatantStats, attack: Attack, critical: bool, seed: u256) -> u8 {
        //TODO: Implement damage calculation
        damage_calculation(self.attack, attack.damage, critical)
    }

    fn did_hit(self: CombatantStats, attack: Attack, seed: u256) -> bool {
        (BitShift::shr(seed, 8) % 100).try_into().unwrap() < attack.accuracy
    }

    fn did_critical(self: CombatantStats, attack: Attack, seed: u256) -> bool {
        let critical: u8 = apply_strength_modifier(attack.critical, self.strength);
        (BitShift::shr(seed, 16) % 255).try_into().unwrap() < critical
    }

    fn is_stunned(self: CombatantState, seed: u256) -> bool {
        (BitShift::shr(seed, 24) % 255).try_into().unwrap() < self.stun_chance
    }

    fn run_stun(ref self: CombatantState, seed: u256) -> bool {
        let stunned = self.is_stunned(seed);
        self.stun_chance = 0;
        stunned
    }
}

#[generate_trait]
impl CombatWorldImp of CombatWorldTraits {
    fn run_attack_check(
        self: IWorldDispatcher, combatant_id: u128, attack: Attack, round: u32
    ) -> bool {
        let attack_available = self.get_available_attack(combatant_id, attack.id);
        if !attack_available.available {
            false
        } else {
            if attack.cooldown == 0 {
                return true;
            }
            let last_used = attack_available.last_used;
            if last_used.is_non_zero() && (attack.cooldown.into() + last_used) > round {
                return false;
            };
            self.set_available_attack(combatant_id, attack.id, round);
            true
        }
    }
    fn emit_attack_event(
        self: IWorldDispatcher,
        combatant_id: u128,
        round: u32,
        attack_id: u128,
        target: u128,
        effect: AttackEffect
    ) { // emit!(self, AttackResult { combatant_id, round, attack_id, target, effect });
    }

    fn run_attack(
        self: IWorldDispatcher,
        attacker_stats: CombatantStats,
        ref attacker_state: CombatantState,
        ref defender_state: CombatantState,
        attack: Attack,
        round: u32,
        hash: HashState
    ) {
        let seed: u256 = hash.update(attacker_stats.id.into()).finalize().into();
        let effect = if !self.run_attack_check(attacker_stats.id, attack, round) {
            AttackEffect::Failed
        } else if attacker_state.run_stun(seed) {
            AttackEffect::Stunned
        } else if attacker_stats.did_hit(attack, seed) {
            let critical = attacker_stats.did_critical(attack, seed);
            let damage = attacker_stats.get_damage(attack, critical, seed);

            defender_state.health.subeq(damage);
            if attack.stun > 0 {
                defender_state
                    .stun_chance =
                        get_new_stun_chance(
                            defender_state.stun_chance, attack.stun, attacker_stats.strength
                        );
            };
            AttackEffect::Hit(AttackHit { damage, stun: attack.stun, critical })
        } else {
            AttackEffect::Miss
        };
        self.emit_attack_event(attacker_stats.id, round, attack.id, defender_state.id, effect);
    }
}

