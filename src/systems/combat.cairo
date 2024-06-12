use core::{
    hash::HashStateTrait, poseidon::{PoseidonTrait, HashState},
    dict::{Felt252Dict, Felt252DictTrait}
};
use alexandria_math::BitShift;
use blob_arena::{
    core::{LimitSub, LimitAdd},
    components::{
        combat::{Phase}, combatant::{Combatant, CombatantTrait}, attack::{Attack},
        utils::{AB, ABT, ABTTrait}
    },
    systems::{attack::AttackSystemTrait},
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
    combatant: Combatant,
    attack: Attack,
    target: u128,
}

#[derive(Drop, Serde, Copy)]
struct CombatWorld {
    world: IWorldDispatcher,
    combat_id: u128,
    round: u32,
    phase: Phase,
}

#[generate_trait]
impl PlannedAttackImpl of PlannedAttackTrait {
    fn get_speed(self: PlannedAttack) -> u8 {
        self.attack.speed + self.combatant.stats.speed
    }
}


#[generate_trait]
impl CombatSystemImpl of CombatSystem {
    fn get_damage(
        self: @Combatant, target: Combatant, attack: Attack, critical: bool, seed: u256
    ) -> u8 {
        //TODO: Implement damage calculation
        0
    }

    fn did_hit(self: @Combatant, target: Combatant, attack: Attack, seed: u256) -> bool {
        (BitShift::shr(seed, 8) % 255).try_into().unwrap() < attack.accuracy
    }

    fn did_critical(self: @Combatant, target: Combatant, attack: Attack, seed: u256) -> bool {
        (BitShift::shr(seed, 16) % 255).try_into().unwrap() < attack.critical
    }

    fn is_stunned(self: @Combatant, seed: u256) -> bool {
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

    fn run_attack_check(self: @CombatWorld, combatant: Combatant, attack: Attack) -> bool {
        if combatant.health.is_non_zero() && combatant.has_attack(attack.id) {
            self.world.run_cooldown(combatant, attack, *self.round)
        } else {
            false
        }
    }

    fn run_attack(
        self: @CombatWorld,
        ref attacker: Combatant,
        ref target: Combatant,
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
        if !attacker.did_hit(target, attack, seed) {
            return AttackResult::Miss;
        }
        let critical = attacker.did_critical(target, attack, seed);
        let damage = attacker.get_damage(target, attack, critical, seed);

        target.health.subeq(damage);
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

