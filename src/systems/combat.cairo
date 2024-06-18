use alexandria_data_structures::array_ext::SpanTraitExt;
use alexandria_data_structures::array_ext::ArrayTraitExt;
use core::{
    hash::HashStateTrait, poseidon::{PoseidonTrait, HashState},
    dict::{Felt252Dict, Felt252DictTrait}
};
use alexandria_math::BitShift;
use blob_arena::{
    core::{LimitSub, LimitAdd, U8ArrayCopyImpl, U128ArrayCopyImpl},
    components::{
        combat::{Phase}, combatant::{CombatantAttributes, CombatantState, CombatantTrait},
        attack::{Attack, AttackTrait}, utils::{AB, ABT, ABTTrait}, stats::{Stats},
    },
// systems::{attack::AttackSystemTrait},
};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


#[derive(Drop, Serde, Copy)]
enum AttackResult {
    Failed,
    Stunned,
    Miss,
    Hit: (u8, u8),
    Critical: (u8, u8),
}

#[derive(Drop, Serde, Copy)]
struct PlannedAttack {
    combatant: u128,
    attack: Attack,
    target: u128,
}

#[derive(Drop, Serde, Copy)]
struct CombatWorld<T> {
    world: IWorldDispatcher,
    combat_id: u128,
    round: u32,
    phase: Phase<T>,
}

// #[generate_trait]
// impl PlannedAttackImpl of PlannedAttackTrait {
//     fn get_speed(self: PlannedAttack) -> u8 {
//         self.attack.speed + self.combatant.stats.speed
//     }
// }

fn get_new_stun_chance(current_stun: u8, attack_stun: u8) -> u8 {
    current_stun
        + attack_stun
        - (current_stun.into() * attack_stun.into() / 255_u16).try_into().unwrap()
}
#[generate_trait]
impl AttackerImpl of AttackerTrait {
    fn get_damage(self: CombatantAttributes, attack: Attack, critical: bool, seed: u256) -> u8 {
        //TODO: Implement damage calculation
        0
    }

    fn did_hit(self: CombatantAttributes, attack: Attack, seed: u256) -> bool {
        (BitShift::shr(seed, 8) % 255).try_into().unwrap() < attack.accuracy
    }

    fn did_critical(self: CombatantAttributes, attack: Attack, seed: u256) -> bool {
        (BitShift::shr(seed, 16) % 255).try_into().unwrap() < attack.critical
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
impl CombatWorldImp<T, +Drop<T>> of CombatWorldTraits<T> {
    fn get_combatant_state(self: CombatWorld<T>, warrior_id: u128) -> CombatantState {
        self.world.get_combatant_state(self.combat_id, warrior_id)
    }
    fn run_cooldown(self: CombatWorld<T>, attacker: CombatantAttributes, attack: Attack,) -> bool {
        if attack.cooldown == 0 {
            return true;
        }
        let last_use = self
            .world
            .get_attack_last_use(self.combat_id, attacker.warrior_id, attack.id);
        if last_use.is_non_zero() && (attack.cooldown.into() + last_use) > self.round {
            return false;
        };
        self.world.set_attack_last_used(self.combat_id, attacker.warrior_id, attack.id, self.round);
        true
    }

    fn run_attack_check(
        self: CombatWorld<T>, attacker: CombatantAttributes, attack: Attack
    ) -> bool {
        if attacker.attacks.contains(attack.id) {
            self.run_cooldown(attacker, attack)
        } else {
            false
        }
    }

    fn run_attack(
        self: CombatWorld<T>,
        attacker_attr: CombatantAttributes,
        ref attacker_state: CombatantState,
        ref defender_state: CombatantState,
        attack: Attack,
        hash: HashState
    ) -> AttackResult {
        if !self.run_attack_check(attacker_attr, attack) { //#
            return AttackResult::Failed;
        }
        let seed: u256 = hash.update(attacker_attr.warrior_id.into()).finalize().into(); //#
        if attacker_state.run_stun(seed) {
            return AttackResult::Stunned;
        }
        if !attacker_attr.did_hit(attack, seed) {
            return AttackResult::Miss;
        }
        let critical = attacker_attr.did_critical(attack, seed);
        let damage = attacker_attr.get_damage(attack, critical, seed);

        defender_state.health.subeq(damage);
        if attack.stun > 0 {
            defender_state
                .stun_chance = get_new_stun_chance(defender_state.stun_chance, attack.stun);
        };

        if critical {
            AttackResult::Critical((damage, attack.stun))
        } else {
            AttackResult::Hit((damage, attack.stun))
        }
    }
}

