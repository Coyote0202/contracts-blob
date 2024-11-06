use core::{hash::HashStateTrait, poseidon::{PoseidonTrait, HashState},};
use blob_arena::{
    core::{SaturatingAdd, SaturatingSub},
    components::{
        combatant::{CombatantState, CombatantTrait}, attack::{Attack, AttackTrait},
        utils::{AB, ABT, ABTTrait}
    },
    utils::UpdateHashToU128, models::CombatantStateStore, systems::{combat::{CombatWorldTraits}},
    models::PlannedAttack,
};
use dojo::{world::{IWorldDispatcher, IWorldDispatcherTrait}, model::Model};


#[generate_trait]
impl PvPCombatSystemImpl of PvPCombatSystemTrait {
    fn run_round(
        self: IWorldDispatcher,
        combatant_ids: ABT<felt252>,
        planned_attacks: ABT<PlannedAttack>,
        round: u32,
        hash: HashState
    ) -> Array<CombatantState> {
        let state_a = self.get_combatant_state(combatant_ids.a);
        let state_b = self.get_combatant_state(combatant_ids.b);
        let attack_a = @self.get_attack(planned_attacks.a.attack);
        let attack_b = @self.get_attack(planned_attacks.b.attack);
        let speed_a = self.get_attacker_attack_speed(@state_a, attack_a);
        let speed_b = self.get_attacker_attack_speed(@state_b, attack_b);

        let switch = if speed_a == speed_b {
            (hash.to_u128() % 2_u128) == 1
        } else {
            speed_a < speed_b
        };
        let (mut state_1, mut state_2, attack_1, attack_2) = if switch {
            (state_b, state_a, attack_b, attack_a)
        } else {
            (state_a, state_b, attack_a, attack_b)
        };

        self.run_attack(ref state_1, ref state_2, attack_1, round, hash);
        if state_1.health > 0 && state_2.health > 0 {
            self.run_attack(ref state_2, ref state_1, attack_2, round, hash);
        };
        state_1.set(self);
        state_2.set(self);
        array![state_1, state_2]
    }
}
