use core::{hash::HashStateTrait, poseidon::{PoseidonTrait, HashState},};
use blob_arena::{
    core::{SaturatingAdd, SaturatingSub},
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

        let speed_a = stats.a.speed + self.get_attack_speed(planned_attacks.a.attack);
        let speed_b = stats.b.speed + self.get_attack_speed(planned_attacks.b.attack);

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
        let attack_1 = self.get_attack(planned_attacks.get(first).attack);
        let attack_2 = self.get_attack(planned_attacks.get(!first).attack);

        self.run_attack(stats_1, stats_2, ref state_1, ref state_2, attack_1, round, hash);
        if state_1.health > 0 && state_2.health > 0 {
            self.run_attack(stats_2, stats_1, ref state_2, ref state_1, attack_2, round, hash);
        }
        state_1.set(self);
        state_2.set(self);
        array![state_1, state_2]
    }
}
