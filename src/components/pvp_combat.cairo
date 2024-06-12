use starknet::{ContractAddress, get_caller_address};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    components::{
        combatant::{Combatant, CombatantTrait}, combat::Phase, utils::{AB, ABT, ABTTrait, ABTImpl}
    },
    models::{PvPCombatModel, PvPCombatStateModel, PvPPlannedAttackModel},
};

type ABCombatants = ABT<Combatant>;
type ABBool = ABT<bool>;

// impl ABCombatantsDrop of Drop<ABCombatants>;
// impl ABCombatantsCopy of Copy<ABCombatants>;
// impl ABCombatantsImpl = ABTImpl<Combatant>;

// impl ABBoolDrop of Drop<ABBool>;
// impl ABBoolCopy of Copy<ABBool>;
// impl ABBoolImpl = ABTImpl<bool>;

#[derive(Drop, Copy)]
struct PvPCombat {
    id: u128,
    combatants: ABCombatants,
    players_state: ABBool,
    phase: Phase,
    round: u32,
}


impl PvPCombatIntoPvPCombatStateModelImpl of Into<PvPCombat, PvPCombatStateModel> {
    fn into(self: PvPCombat) -> PvPCombatStateModel {
        PvPCombatStateModel {
            id: self.id,
            players_state: self.players_state.into(),
            phase: self.phase,
            round: self.round,
        }
    }
}


#[generate_trait]
impl PvPCombatImpl of PvPCombatTrait {
    fn make_pvp_combat(id: u128, combatants: ABCombatants, players_state: ABBool) -> PvPCombat {
        PvPCombat { id, combatants, players_state, phase: Phase::Setup, round: 0, }
    }

    fn _get_pvp_combat_models(
        self: @IWorldDispatcher, id: u128
    ) -> (PvPCombatModel, PvPCombatStateModel) {
        get!((*self), id, (PvPCombatModel, PvPCombatStateModel))
    }

    fn get_pvp_combat(self: @IWorldDispatcher, id: u128) -> PvPCombat {
        let (model, state) = self._get_pvp_combat_models(id);
        let (combatant_a, combatant_b) = model.combatants;
        let combatants = ABTTrait::new(
            self.get_combatant(id, combatant_a), self.get_combatant(id, combatant_b),
        );
        let players_state = ABTTrait::new_from_tuple(state.players_state);
        PvPCombat { id, combatants, players_state, phase: state.phase, round: state.round, }
    }
    fn set_pvp_combat_state(self: @IWorldDispatcher, combat: PvPCombat) {
        let state: PvPCombatStateModel = combat.into();
        set!((*self), (state,));
    }
    fn set_planned_attack(
        self: @IWorldDispatcher, combat_id: u128, warrior_id: u128, attack: u128
    ) {
        set!((*self), PvPPlannedAttackModel { combat_id, warrior_id, attack });
    }
    fn get_planned_attack(self: @IWorldDispatcher, combat_id: u128, warrior_id: u128) -> u128 {
        get!((*self), (combat_id, warrior_id), PvPPlannedAttackModel).attack
    }
}

#[generate_trait]
impl ABCombatantImpl of ABCombatatTrait {
    fn get_combatant_ab(self: @ABCombatants, warrior_id: u128) -> AB {
        if warrior_id == *self.a.warrior_id {
            AB::A
        } else if warrior_id == *self.b.warrior_id {
            AB::B
        } else {
            panic!("Invalid warrior_id")
        }
    }
    fn get_combatant(self: @ABCombatants, warrior_id: u128) -> Combatant {
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
    fn both_true(self: @ABBool) -> bool {
        *self.a && *self.b
    }
    fn reset(ref self: ABBool) {
        self.a = false;
        self.b = false;
    }
}

#[generate_trait]
impl PvPPlannedAttackImpl of PvPPlannedAttackTrait {}

