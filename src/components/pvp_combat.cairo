use starknet::{ContractAddress, get_caller_address, get_block_number};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    core::U8ArrayCopyImpl,
    components::{
        attack::{Attack, AttackTrait}, combatant::{CombatantInfo, CombatantState, CombatantTrait},
        combat::{Phase,}, utils::{AB, ABT, ABTTrait, ABTImpl}
    },
    models::{PvPCombatModel, PvPCombatStateModel, PvPPlannedAttackModel, PvPPhase, PvPWinner},
};


#[derive(Drop, Copy)]
struct PvPCombat {
    combat_id: u128,
    combatants: ABT<CombatantInfo>,
    phase: PvPPhase,
    round: u32,
}


impl PvPCombatIntoPvPCombatStateModelImpl of Into<PvPCombat, PvPCombatStateModel> {
    fn into(self: PvPCombat) -> PvPCombatStateModel {
        PvPCombatStateModel {
            id: self.combat_id,
            phase: self.phase,
            round: self.round,
            block_number: get_block_number()
        }
    }
}


#[generate_trait]
impl PvPCombatImpl of PvPCombatTrait {
    fn make_pvp_combat(
        combat_id: u128, combatants: ABT<CombatantInfo>, players_state: ABT<bool>
    ) -> PvPCombat {
        PvPCombat { combat_id, combatants, phase: PvPPhase::Setup, round: 0, }
    }


    fn get_pvp_combat_model(self: IWorldDispatcher, id: u128) -> PvPCombatModel {
        get!(self, id, PvPCombatModel)
    }
    fn get_pvp_combat_state_model(self: IWorldDispatcher, id: u128) -> PvPCombatStateModel {
        get!(self, id, PvPCombatStateModel)
    }

    fn get_pvp_planned_attack(self: IWorldDispatcher, combat_id: u128, warrior_id: u128) -> u128 {
        get!(self, (combat_id, warrior_id), PvPPlannedAttackModel).attack
    }

    fn get_pvp_attacks(self: IWorldDispatcher, combatants: ABT<CombatantInfo>) -> ABT<Attack> {
        ABTTrait::new(
            self
                .get_attack(
                    self.get_pvp_planned_attack(combatants.a.combat_id, combatants.a.warrior_id)
                ),
            self
                .get_attack(
                    self.get_pvp_planned_attack(combatants.b.combat_id, combatants.b.warrior_id)
                )
        )
    }

    fn _get_pvp_combat_models(
        self: IWorldDispatcher, id: u128
    ) -> (PvPCombatModel, PvPCombatStateModel) {
        get!(self, id, (PvPCombatModel, PvPCombatStateModel))
    }

    fn get_pvp_combat(self: IWorldDispatcher, combat_id: u128) -> PvPCombat {
        let (model, state) = self._get_pvp_combat_models(combat_id);
        let (combatant_a, combatant_b) = model.combatants;
        let combatants = ABTTrait::new(
            self.get_combatant_info(combat_id, combatant_a),
            self.get_combatant_info(combat_id, combatant_b),
        );
        let players_state = ABTTrait::new_from_tuple(state.players_state);
        PvPCombat { combat_id, combatants, players_state, phase: state.phase, round: state.round, }
    }

    fn assert_running(self: PvPCombat) {
        match self.phase {
            Phase::Setup | Phase::Ended => { panic!("Combat not running") },
            _ => {}
        };
    }
    fn set_pvp_combat_state(self: IWorldDispatcher, combat: PvPCombat) {
        let combat_state: PvPCombatStateModel = combat.into();
        set!(self, (combat_state,)); //#
    }
    fn set_planned_attack(self: IWorldDispatcher, combat_id: u128, warrior_id: u128, attack: u128) {
        set!(self, (PvPPlannedAttackModel { combat_id, warrior_id, attack },));
    }
    fn get_planned_attack(self: IWorldDispatcher, combat_id: u128, warrior_id: u128) -> u128 {
        get!(self, (combat_id, warrior_id), PvPPlannedAttackModel).attack
    }

    fn end_game(self: IWorldDispatcher, combat_id: u128, winner: PvPWinner) {
        let mut state = self.get_pvp_combat_state_model(combat_id);
        state.phase = PvPPhase::Ended(winner);
        set!(self, (state,));
    }
}

#[generate_trait]
impl ABCombatantImpl of ABCombatantTrait {
    fn get_combatant_ab(self: @ABT<CombatantInfo>, warrior_id: u128) -> AB {
        if warrior_id == *self.a.warrior_id {
            AB::A
        } else if warrior_id == *self.b.warrior_id {
            AB::B
        } else {
            panic!("Invalid warrior_id")
        }
    }
    fn get_combatant(self: @ABT<CombatantInfo>, warrior_id: u128) -> CombatantInfo {
        if warrior_id == *self.a.warrior_id {
            *self.a
        } else if warrior_id == *self.b.warrior_id {
            *self.b
        } else {
            panic!("Invalid warrior_id")
        }
    }
}

#[generate_trait]
impl ABStateImpl of ABStateTrait {
    fn both_true(self: ABT<bool>) -> bool {
        self.a && self.b
    }
    fn reset(ref self: ABT<bool>) {
        self.a = false;
        self.b = false;
    }
}

#[generate_trait]
impl ABCombatantStateImpl of ABCombatantStateTrait {
    fn get_winner(self: ABT<CombatantState>) -> PvPWinner {
        if self.b.health.is_zero() && self.a.health.is_non_zero() {
            PvPWinner::A
        } else if self.a.health.is_zero() && self.b.health.is_non_zero() {
            PvPWinner::B
        } else {
            PvPWinner::None
        }
    }
    fn is_running(self: ABT<CombatantState>) -> bool {
        self.a.health.is_non_zero() && self.b.health.is_non_zero()
    }
}

#[generate_trait]
impl PvPPlannedAttackImpl of PvPPlannedAttackTrait {}

