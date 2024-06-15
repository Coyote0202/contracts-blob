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
        combat::{Phase},
        combatant::{
            Combatant, CombatantAttributes, CombatantState, CombatantTrait, Attacker, Defender
        },
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
#[generate_trait]
impl AttackerImpl of AttackerTrait {
    fn get_damage(self: Combatant, attack: Attack, critical: bool, seed: u256) -> u8 {
        //TODO: Implement damage calculation
        0
    }

    fn did_hit(self: Combatant, attack: Attack, seed: u256) -> bool {
        (BitShift::shr(seed, 8) % 255).try_into().unwrap() < attack.accuracy
    }

    fn did_critical(self: Combatant, attack: Attack, seed: u256) -> bool {
        (BitShift::shr(seed, 16) % 255).try_into().unwrap() < attack.critical
    }

    fn is_stunned(self: Combatant, seed: u256) -> bool {
        let (mut n, len) = (0_usize, self.stun_chances.len());
        let mut stunned = false;
        while n < len {
            let val = (BitShift::shr(seed, 8 * n.into() + 32) % 255).try_into().unwrap();
            if val < *self.stun_chances[n] {
                stunned = true;
                break;
            }
            n += 1;
        };
        return false;
    }

    fn run_stun(ref self: Combatant, seed: u256) -> bool {
        let stunned = self.is_stunned(seed);
        self.stun_chances = ArrayTrait::new();
        stunned
    }
}

#[generate_trait]
impl CombatWorldImp<T, +Drop<T>> of CombatWorldTraits<T> {
    fn run_cooldown(self: CombatWorld<T>, attacker: Combatant, attack: Attack,) -> bool {
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

    fn run_attack_check(self: CombatWorld<T>, attacker: Combatant, attack: Attack) -> bool {
        if attacker.attacks.contains(attack.id) {
            self.run_cooldown(attacker, attack)
        } else {
            false
        }
    }

    fn run_attack(
        self: CombatWorld<T>,
        ref attacker: Combatant,
        ref defender: Combatant,
        attack: Attack,
        hash: HashState
    ) -> AttackResult {
        if !self.run_attack_check(attacker, attack) {
            return AttackResult::Failed;
        }

        let seed = hash.update(attacker.warrior_id.into()).finalize().into();
        if attacker.run_stun(seed) {
            return AttackResult::Stunned;
        }
        if !attacker.did_hit(attack, seed) {
            return AttackResult::Miss;
        }
        let critical = attacker.did_critical(attack, seed);
        let damage = attacker.get_damage(attack, critical, seed);

        defender.health.subeq(damage);
        if attack.stun > 0 {
            attacker.stun_chances.append(attack.stun)
        };

        if critical {
            AttackResult::Critical((damage, attack.stun))
        } else {
            AttackResult::Hit((damage, attack.stun))
        }
    }
}

