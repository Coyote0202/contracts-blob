// For testing only

use starknet::{ContractAddress, get_caller_address};
#[dojo::interface]
trait IPvPAdminActions {
    fn create_challenge(
        collection_address: ContractAddress,
        player_1: ContractAddress,
        player_2: ContractAddress,
        token_1_id: u256,
        token_2_id: u256
    ) -> u128;
    fn set_winner(combatant_id: u128);
}

mod pvp_admin_actions {
    use starknet::{ContractAddress, get_caller_address};
    use blob_arena::components::{pvp_combat::PvPCombatTrait, world::Contracts};
    use super::IPvPAdminActions;

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn assert_is_admin(self: @IWorldDispatcher) {
            assert(world.is_writer(get_caller_address(), 'pvp_admin_actions'), 'Not Admin');
        }
    }
    #[abi(embed_v0)]
    impl IPvPAdminActionsImpl of IPvPAdminActions<ContractState> {
        fn create_challenge(
            ref world: IWorldDispatcher,
            collection_address: ContractAddress,
            player_a: ContractAddress,
            player_b: ContractAddress,
            token_a_id: u256,
            token_b_id: u256
        ) -> u128 {
            world.assert_is_admin();
            let caller = get_caller_address();
            let combat_id = uuid(world);
            world.is_owner(caller, 'pvp_admin_actions')
            let mut combatant_a = create_combatant(
                world, collection_address, token_a_id, combat_id
            );
            let mut combatant_b = create_combatant(
                world, collection_address, token_b_id, combat_id
            );
            combatant_a.player = player_a;
            combatant_b.player = player_b;
            world.set_combatant(combatant_a);
            world.set_combatant(combatant_b);
            world.new_pvp_combat_state_model(combat_id);
            world.set_pvp_combatants(combat_id, (combatant_a.id, combatant_b.id));
            combat_id
        }
        fn set_winner(ref world: IWorldDispatcher, combatant_id: u128) {
            world.assert_is_admin();
        }
    }
}

