use alexandria_data_structures::array_ext::SpanTraitExt;
use alexandria_data_structures::array_ext::ArrayTraitExt;
use core::{
    hash::HashStateTrait, poseidon::{PoseidonTrait, HashState},
    dict::{Felt252Dict, Felt252DictTrait}
};
use alexandria_math::BitShift;
use blob_arena::{
    core::{LimitSub, LimitAdd},
    components::{
        combat::{Phase, AttackResult, AttackHit},
        combatant::{CombatantState, CombatantStats, CombatantInfo, CombatantTrait},
        attack::{Attack, AttackTrait, AvailableAttack}, utils::{AB, ABT, ABTTrait}, stats::{Stats},
    },
    models::{AttackEvent},
};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


#[derive(Drop, Serde, Copy)]
struct PlannedAttack {
    combatant: u128,
    attack: Attack,
    target: u128,
}

fn get_new_stun_chance(current_stun: u8, attack_stun: u8) -> u8 {
    current_stun
        + attack_stun
        - (current_stun.into() * attack_stun.into() / 255_u16).try_into().unwrap()
}


#[generate_trait]
impl AttackerImpl of AttackerTrait {
    fn get_damage(self: CombatantStats, attack: Attack, critical: bool, seed: u256) -> u8 {
        //TODO: Implement damage calculation
        let mut damage: u32 = attack.damage.into();
        damage *= if critical {
            17
        } else {
            10
        };
        damage /= 10;
        if damage > 255 {
            damage = 255;
        }
        damage.try_into().unwrap()
    }

    fn did_hit(self: CombatantStats, attack: Attack, seed: u256) -> bool {
        (BitShift::shr(seed, 8) % 255).try_into().unwrap() < attack.accuracy
    }

    fn did_critical(self: CombatantStats, attack: Attack, seed: u256) -> bool {
        let mut critical: u32 = attack.critical.into();
        critical *= 255 + self.strength.into();

        (BitShift::shr(seed, 16) % 65536).try_into().unwrap() < critical
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
        attack: u128,
        target: u128,
        result: AttackResult
    ) {
        emit!(self, AttackEvent { combatant_id, round, attack, target, result });
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
        let result = if !self.run_attack_check(attacker_stats.id, attack, round) {
            AttackResult::Failed
        } else if attacker_state.run_stun(seed) {
            AttackResult::Stunned
        } else if attacker_stats.did_hit(attack, seed) {
            let critical = attacker_stats.did_critical(attack, seed);
            let damage = attacker_stats.get_damage(attack, critical, seed);

            defender_state.health.subeq(damage);
            if attack.stun > 0 {
                defender_state
                    .stun_chance = get_new_stun_chance(defender_state.stun_chance, attack.stun);
            };
            AttackResult::Hit(AttackHit { damage, stun: attack.stun, critical })
        } else {
            AttackResult::Miss
        };
        self.emit_attack_event(attacker_stats.id, round, attack.id, defender_state.id, result);
    }
}
// fn run_attacks(
//      self: IWorldDispatcher,
//     combatant_stats: Felt252Dict<Box<CombatantStats>>,
//     combatant_states: Felt252Dict<CombatantState>,
//     planned_attacks: Span<PlannedAttack>
// ) {
//     let (mut n, len) = (0, planned_attacks.len());
//     while n < len {
//         let planned_attack = planned_attacks.at(n);
//         let attacker_stats = combatant_stats.get(planned_attack.combatant.into());

//         let attacker_state = combatant_states.get(planned_attack.combatant);
//         let defender_state = combatant_states.get(planned_attack.target);
//         let attack = planned_attack.attack;
//         let result = self
//             .run_attack(
//                 attacker_stats,
//                 attacker_state,
//                 defender_state,
//                 attack,
//                 self.round,
//                 self.world.get_hash()
//             );
//         self
//             .emit_attack_event(
//                 planned_attack.combatant,
//                 self.round,
//                 attack.id,
//                 planned_attack.target,
//                 result.into()
//             );
//         n += 1;
//     }
// }


