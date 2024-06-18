use core::{hash::HashStateTrait, poseidon::{PoseidonTrait, HashState},};
use alexandria_math::BitShift;
use blob_arena::{
    core::{LimitSub, LimitAdd},
    components::{
        combatant::{CombatantInfo, CombatantState, CombatantTrait}, attack::{Attack, AttackTrait},
        utils::{AB, ABT, ABTTrait}, pvp_combat::{PvPCombat, PvPPhase as Phase, PvPWinner as Winner}
    },
    systems::{combat::{AttackResult, CombatWorld, CombatWorldTraits}},
};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


type PvPCombatWorld = CombatWorld<Winner>;


#[generate_trait]
impl PvPCombatSystemImpl of PvPCombatSystemTrait {
    fn to_pvp_combat_world(self: IWorldDispatcher, combat: PvPCombat) -> PvPCombatWorld {
        PvPCombatWorld {
            world: self, combat_id: combat.combat_id, round: combat.round, phase: combat.phase,
        }
    }

    fn run_round(
        self: PvPCombatWorld, combatants: ABT<CombatantInfo>, attacks: ABT<Attack>, hash: HashState
    // -> (ABT<CombatantState>, ABT<AttackResult>) 

    ) {
        let speed_a = attacks.a.speed + combatants.a.stats.speed;
        let speed_b = attacks.b.speed + combatants.b.stats.speed;

        let first = if speed_a > speed_b {
            AB::A
        } else if speed_a < speed_b {
            AB::B
        } else {
            (hash.finalize().try_into().unwrap() % 2_u128).into()
        };
        let mut state_1 = self.get_combatant_state(combatants.get(first).warrior_id);
        let mut state_2 = self.get_combatant_state(combatants.get(!first).warrior_id);
        let result_1 = self
            .run_attack(combatants.get(first), ref state_1, ref state_2, attacks.get(first), hash);
        let result_2 = self
            .run_attack(
                combatants.get(!first), ref state_2, ref state_1, attacks.get(!first), hash
            );
    // match first {
    //     AB::A => (ABTTrait::new(state_1, state_2), ABTTrait::new(result_1, result_2)),
    //     AB::B => (ABTTrait::new(state_2, state_1), ABTTrait::new(result_2, result_1)),
    // };
    // (ABTTrait::new(state_1, state_2), ABTTrait::new(AttackResult::Failed, AttackResult::Failed))
    }
    fn end_game(ref self: PvPCombatWorld, winner: Winner) {
        self.phase = Phase::Ended(winner);
    }
}
