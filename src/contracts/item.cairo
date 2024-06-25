use blob_arena::components::stats::Stats;
use dojo::world::{IWorldDispatcher};

#[dojo::interface]
trait IItemActions {
    fn new_item(
        ref world: IWorldDispatcher, name: ByteArray, stats: Stats, attacks: Array<u128>
    ) -> u128;
    fn update_item(
        ref world: IWorldDispatcher, id: u128, name: ByteArray, stats: Stats, attacks: Array<u128>
    );
}

#[dojo::contract]
mod item_actions {
    use starknet::{ContractAddress, get_caller_address, get_contract_address};

    use blob_arena::{
        components::{stats::Stats, world::{WorldTrait, Contract}}, models::ItemModel, utils::uuid
    };

    use super::IItemActions;

    #[abi(embed_v0)]
    impl IItemActionsImpl of IItemActions<ContractState> {
        fn new_item(
            ref world: IWorldDispatcher, name: ByteArray, stats: Stats, attacks: Array<u128>
        ) -> u128 {
            let id = uuid(world);
            let item = ItemModel { id, name, stats, attacks };
            world.assert_caller_is_writer(Contract::Item);
            set!(world, (item,));
            id
        }
        fn update_item(
            ref world: IWorldDispatcher,
            id: u128,
            name: ByteArray,
            stats: Stats,
            attacks: Array<u128>
        ) {
            world.assert_caller_is_owner(get_contract_address());
            let item = ItemModel { id, name, stats, attacks };
            set!(world, (item,));
        }
    }
}
