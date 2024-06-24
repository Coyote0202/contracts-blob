use blob_arena::components::stats::Stats;
use dojo::world::{IWorldDispatcher};

#[dojo::interface]
trait IItemActions {
    fn set_item(
        ref world: IWorldDispatcher, name: ByteArray, stats: Stats, attacks: Array<u128>
    ) -> u128;
}

#[dojo::contract]
mod item_actions {
    use starknet::{ContractAddress, get_caller_address};

    use blob_arena::{
        components::{stats::Stats, world::{WorldTrait, Contract}}, models::ItemModel, utils::uuid
    };

    use super::IItemActions;

    #[abi(embed_v0)]
    impl IItemActionsImpl of IItemActions<ContractState> {
        fn set_item(
            ref world: IWorldDispatcher, name: ByteArray, stats: Stats, attacks: Array<u128>
        ) -> u128 {
            let id = uuid(world);
            let item = ItemModel { id, name, stats, attacks: attacks, };
            world.assert_caller_is_writer(Contract::Item);
            set!(world, (item,));
            id
        }
    }
}
