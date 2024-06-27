// For testing only
use starknet::{ContractAddress};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


#[dojo::interface]
trait IPvPAdminActions {
    fn create_challenge(
        ref world: IWorldDispatcher,
        collection_address_a: ContractAddress,
        collection_address_b: ContractAddress,
        player_a: ContractAddress,
        player_b: ContractAddress,
        token_a_id: u256,
        token_b_id: u256
    ) -> u128;
    fn set_winner(ref world: IWorldDispatcher, combatant_id: u128);
}

#[dojo::contract]
mod pvp_admin_actions {
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use blob_arena::{
        components::{
            combatant::CombatantTrait, combat::CombatStateTrait, pvp_combat::PvPCombatTrait,
        },
        utils::uuid, world::{Contract, WorldTrait}
    };
    use super::IPvPAdminActions;

    #[abi(embed_v0)]
    impl IPvPAdminActionsImpl of IPvPAdminActions<ContractState> {
        fn create_challenge(
            ref world: IWorldDispatcher,
            collection_address_a: ContractAddress,
            collection_address_b: ContractAddress,
            player_a: ContractAddress,
            player_b: ContractAddress,
            token_a_id: u256,
            token_b_id: u256
        ) -> u128 {
            world.assert_caller_is_owner(get_contract_address());
            let combat_id = uuid(world);
            let mut combatant_a = world
                .create_combatant(collection_address_a, token_a_id, combat_id);
            let mut combatant_b = world
                .create_combatant(collection_address_b, token_b_id, combat_id);
            combatant_a.player = player_a;
            combatant_b.player = player_b;
            world.set_combatant(combatant_a);
            world.set_combatant(combatant_b);
            world.new_combat_state(combat_id);
            world.set_pvp_combatants(combat_id, (combatant_a.id, combatant_b.id));
            combat_id
        }
        fn set_winner(ref world: IWorldDispatcher, combatant_id: u128) {
            world.assert_caller_is_owner(get_contract_address());
        }
    }
}

