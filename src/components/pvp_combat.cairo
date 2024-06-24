use starknet::{ContractAddress, get_caller_address, get_block_number};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    components::{
        attack::{Attack, AttackTrait}, combatant::{CombatantInfo, CombatantState, CombatantTrait},
        combat::{Phase,}, utils::{AB, ABT, ABTTrait, ABTImpl}
    },
    models::{PvPCombatantsModel, PvPCombatStateModel, PvPPlannedAttackModel, PvPPhase, PvPWinner},
};


#[derive(Drop, Copy)]
struct PvPCombatWorld {
    world: IWorldDispatcher,
    combat_id: u128,
    combatants: ABT<u128>,
    phase: PvPPhase,
    round: u32,
}


impl PvPCombatIntoPvPCombatStateModelImpl of Into<PvPCombatWorld, PvPCombatStateModel> {
    fn into(self: PvPCombatWorld) -> PvPCombatStateModel {
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
    fn get_pvp_combat_world(self: @IWorldDispatcher, combat_id: u128) -> PvPCombatWorld {
        let state = self.get_pvp_combat_state_model(combat_id);
        let combatants = self.get_pvp_combatants(combat_id);
        PvPCombatWorld {
            world: (*self), combat_id, combatants, phase: state.phase, round: state.round,
        }
    }
    fn get_pvp_combatants(self: @IWorldDispatcher, id: u128) -> ABT<u128> {
        ABTTrait::new_from_tuple(get!((*self), id, PvPCombatantsModel).combatants)
    }

    fn get_pvp_combat_state_model(self: @IWorldDispatcher, id: u128) -> PvPCombatStateModel {
        get!((*self), id, PvPCombatStateModel)
    }

    fn get_pvp_planned_attack(self: @IWorldDispatcher, combat_id: u128, warrior_id: u128) -> u128 {
        get!((*self), (combat_id, warrior_id), PvPPlannedAttackModel).attack
    }

    fn get_pvp_attacks(self: @IWorldDispatcher, combatants: ABT<CombatantInfo>) -> ABT<Attack> {
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
        self: @IWorldDispatcher, id: u128
    ) -> (PvPCombatantsModel, PvPCombatStateModel) {
        get!((*self), id, (PvPCombatantsModel, PvPCombatStateModel))
    }

    fn assert_running(self: @PvPCombatWorld) {
        match *self.phase {
            Phase::Setup | Phase::Ended => { panic!("Combat not running") },
            _ => {}
        };
    }
    fn set_pvp_combat_state(ref self: IWorldDispatcher, combat: PvPCombatWorld) {
        let combat_state: PvPCombatStateModel = combat.into();
        set!(self, (combat_state,));
    }
    fn set_planned_attack(
        ref self: IWorldDispatcher, combat_id: u128, warrior_id: u128, attack: u128
    ) {
        set!(self, (PvPPlannedAttackModel { combat_id, warrior_id, attack },));
    }
    fn get_planned_attack(self: @IWorldDispatcher, combat_id: u128, warrior_id: u128) -> u128 {
        get!((*self), (combat_id, warrior_id), PvPPlannedAttackModel).attack
    }

    fn end_game(ref self: PvPCombatWorld, combat_id: u128, winner: PvPWinner) {
        self.phase = PvPPhase::Ended(winner);
        let state: PvPCombatStateModel = self.into();
        set!(self.world, (state,));
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

