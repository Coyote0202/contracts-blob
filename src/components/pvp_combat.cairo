use starknet::{ContractAddress, get_caller_address, get_block_number};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    components::{
        attack::{Attack, AttackTrait}, combatant::{CombatantInfo, CombatantState, CombatantTrait},
        combat::{Phase,}, utils::{AB, ABT, ABTTrait, ABTImpl, ABTLogicTrait}
    },
    models::{PvPCombatantsModel, CombatState},
};


#[generate_trait]
impl PvPCombatImpl of PvPCombatTrait {
    fn set_pvp_combatants<T, +Into<T, (u128, u128)>>(
        self: IWorldDispatcher, id: u128, combatants: T
    ) {
        set!(self, PvPCombatantsModel { id, combatants: combatants.into() });
    }
    fn get_pvp_combatants_model(self: @IWorldDispatcher, id: u128) -> PvPCombatantsModel {
        get!((*self), id, PvPCombatantsModel)
    }
    fn get_pvp_combatants(self: @IWorldDispatcher, id: u128) -> ABT<u128> {
        let combatants = ABTTrait::new_from_tuple(self.get_pvp_combatants_model(id).combatants);
        assert(combatants.is_neither_zero(), 'Combatants not set');
        combatants
    }
}
