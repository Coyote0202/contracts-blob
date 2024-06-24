use core::{hash::HashStateTrait, poseidon::{PoseidonTrait, HashState},};
use alexandria_math::BitShift;
use blob_arena::{
    core::{LimitSub, LimitAdd},
    components::{
        combatant::{CombatantStats, CombatantState, CombatantTrait}, attack::{Attack, AttackTrait},
        utils::{AB, ABT, ABTTrait}
    },
    systems::{combat::{AttackResult, CombatWorldTraits}},
};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


#[derive(Clone, Copy, Drop)]
struct PlannedAttack {
    combatant: u128,
    attack: Attack,
    target: u128,
}

#[generate_trait]
impl PvPCombatSystemImpl of PvPCombatSystemTrait {
    fn run_round(
        ref self: IWorldDispatcher,
        combatant_ids: ABT<u128>,
        attack_ids: ABT<u128>,
        round: u32,
        hash: HashState
    ) -> ABT<CombatantState> {
        let stats = ABTTrait::new(
            self.get_combatant_stats(combatant_ids.a), self.get_combatant_stats(combatant_ids.b)
        );
        let attacks = ABTTrait::new(self.get_attack(attack_ids.a), self.get_attack(attack_ids.b));

        let speed_a = attacks.a.speed + stats.a.speed;
        let speed_b = attacks.b.speed + stats.b.speed;

        let first = if speed_a > speed_b {
            AB::A
        } else if speed_a < speed_b {
            AB::B
        } else {
            (hash.finalize().try_into().unwrap() % 2_u128).into()
        };

        let stats_1 = self.get_combatant_stats(combatant_ids.get(first));
        let stats_2 = self.get_combatant_stats(combatant_ids.get(!first));
        let mut state_1 = self.get_combatant_state(combatant_ids.get(first));
        let mut state_2 = self.get_combatant_state(combatant_ids.get(!first));
        self.run_attack(stats_1, ref state_1, ref state_2, attacks.get(first), round, hash);
        self.run_attack(stats_2, ref state_2, ref state_1, attacks.get(!first), round, hash);
        set!(self, (state_1, state_2));

        match first {
            AB::A => (ABTTrait::new(state_1, state_2)),
            AB::B => (ABTTrait::new(state_2, state_1)),
        }
    }
}
