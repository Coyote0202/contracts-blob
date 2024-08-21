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
        token_b_id: u256,
        attacks_a: Span<(u128, u128)>,
        attacks_b: Span<(u128, u128)>,
    ) -> u128;
    fn set_winner(ref world: IWorldDispatcher, combatant_id: u128);
}

#[dojo::contract]
mod pvp_admin_actions {
    use starknet::{ContractAddress, get_caller_address, get_contract_address};
    use blob_arena::{
        collections::interface::get_collection_dispatcher,
        components::{
            combatant::CombatantTrait, combat::{CombatStateTrait, CombatStatesTrait},
            pvp_combat::PvPCombatTrait, pvp_challenge::PvPChallengeScoreTrait, utils::ABTOtherTrait
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
            token_b_id: u256,
            attacks_a: Span<(u128, u128)>,
            attacks_b: Span<(u128, u128)>,
        ) -> u128 {
            world.assert_caller_is_owner();
            let combat_id = uuid(world);
            let collection_a = get_collection_dispatcher(collection_address_a);
            let collection_b = get_collection_dispatcher(collection_address_b);
            let combatant_a = world
                .create_combatant(collection_a, token_a_id, combat_id, player_a, attacks_a);
            let combatant_b = world
                .create_combatant(collection_b, token_b_id, combat_id, player_b, attacks_b);
            world.new_combat_state(combat_id);
            world.set_pvp_combatants(combat_id, (combatant_a.id, combatant_b.id));
            combat_id
        }
        fn set_winner(ref world: IWorldDispatcher, combatant_id: u128) {
            world.assert_caller_is_owner();

            let winner = world.get_combatant_info(combatant_id);
            let mut combat = world.get_running_combat_state(winner.combat_id);
            let combatants = world.get_pvp_combatants(combat.id);
            let loser = world.get_combatant_info(combatants.other(winner.id));
            world.end_combat(combat, winner.id);
            world.update_scores(winner, loser);
        }
    }
}

