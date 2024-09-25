use core::{hash::HashStateTrait, poseidon::{PoseidonTrait, HashState},};
use blob_arena::{
    core::{LimitSub, LimitAdd},
    components::{
        combatant::{CombatantStats, CombatantState, CombatantTrait}, attack::{Attack, AttackTrait},
        utils::{AB, ABT, ABTTrait}
    },
    systems::{combat::{AttackEffect, CombatWorldTraits}}, models::PlannedAttack,
};
use dojo::{world::{IWorldDispatcher, IWorldDispatcherTrait}, model::Model};


// #[derive(Clone, Copy, Drop)]
// struct PlannedAttack {
//     combatant: u128,
//     attack: Attack,
//     target: u128,
// }

#[generate_trait]
impl PvPCombatSystemImpl of PvPCombatSystemTrait {
    fn run_round(
        self: IWorldDispatcher,
        combatant_ids: ABT<u128>,
        planned_attacks: ABT<PlannedAttack>,
        round: u32,
        hash: HashState
    ) -> Array<CombatantState> {
        let stats = ABTTrait::new(
            self.get_combatant_stats(combatant_ids.a), self.get_combatant_stats(combatant_ids.b)
        );
        let attacks = ABTTrait::new(
            self.get_attack(planned_attacks.a.attack), self.get_attack(planned_attacks.b.attack)
        );

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
        let state_1 = self.get_combatant_state(combatant_ids.get(first));
        let state_2 = self.get_combatant_state(combatant_ids.get(!first));

        let (state_1, state_2) = self
            .run_attack(stats_1, state_1, state_2, attacks.get(first), round, hash);
        let (state_2, state_1) = self
            .run_attack(stats_2, state_2, state_1, attacks.get(!first), round, hash);
        state_1.set(self);
        state_2.set(self);
        array![state_1, state_2]
    }
}
