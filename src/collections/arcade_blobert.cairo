#[starknet::interface]
trait IArcadeBlobertActions<TContractState> {
    fn mint(self: @TContractState>, );
}


#[dojo::contract]
mod arcade_blobert_actions {
    use starknet::ContractAddress;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use token::{erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait}};
    use blob_arena::collections::{
        interface::ICollectionActions,
        blobert::external::{get_erc271_dispatcher, get_blobert_dispatcher, IBlobertDispatcher},
    };
    use super::IArcadeBlobertActions;



    #[abi(embed_v0)]
    impl IArcadeBlobertActionsImpl of IArcadeBlobertActions<ContractState> {
        fn mint(self: @ContractState) {
            let world = self.world_dispatcher.read();
            

        }
    }

    #[abi(embed_v0)]
    impl ICollectionActionsDispatcherImpl of ICollectionActions<ContractState> {
        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            let dispatcher = get_erc271_dispatcher();
            IERC721DispatcherTrait::owner_of(dispatcher, token_id)
        }

        fn get_items(self: @ContractState, token_id: u256) -> Array<u128> {
            let dispatcher = get_blobert_dispatcher();
            ArrayTrait::new()
        }
    }
}