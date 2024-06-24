use blob_arena::components::stats::Stats;
use dojo::world::{IWorldDispatcher};

struct Item {
    name: ByteArray,
    stats: Stats,
    attacks: Span<u128>,
}

#[dojo::interface]
trait IItemsActions {
    fn set_item(
        ref world: IWorldDispatcher, name: ByteArray, stats: Stats, attacks: Array<u128>
    ) -> u128;
    fn set_items(ref world: IWorldDispatcher, items: Span<Item>) -> u128;
}

#[dojo::contract]
mod items_actions {
    use super::IItemsActions;
    use starknet::{ContractAddress, get_caller_address};

    use blob_arena::components::stats::Stats;


    #[abi(embed_v0)]
    impl IItemsActionsImpl of IItemsActions {
        fn set_item(
            ref world: IWorldDispatcher, name: ByteArray, stats: Stats, attacks: Array<u128>
        ) -> u128 {}
    }
}
