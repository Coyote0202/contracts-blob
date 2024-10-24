use blob_arena::components::{stats::Stats, item::AttackInput};
use dojo::world::{IWorldDispatcher};

#[dojo::interface]
trait IItemActions {
    fn new_item(ref world: IWorldDispatcher, name: ByteArray, stats: Stats) -> felt252;
    fn new_item_with_attacks(
        ref world: IWorldDispatcher, name: ByteArray, stats: Stats, attacks: Array<AttackInput>
    ) -> felt252;
}

#[dojo::contract]
mod item_actions {
    use starknet::{ContractAddress, get_caller_address, get_contract_address};

    use blob_arena::{components::{stats::Stats, item::{ItemTrait, AttackInput}}};

    use super::{IItemActions};


    #[abi(embed_v0)]
    impl IItemActionsImpl of IItemActions<ContractState> {
        fn new_item(ref world: IWorldDispatcher, name: ByteArray, stats: Stats) -> felt252 {
            world.create_new_item(name, stats)
        }
        fn new_item_with_attacks(
            ref world: IWorldDispatcher, name: ByteArray, stats: Stats, attacks: Array<AttackInput>
        ) -> felt252 {
            let id = world.create_new_item(name, stats);
            world.create_and_set_new_attacks(id, attacks);
            id
        }
    }
}
