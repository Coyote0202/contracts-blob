mod external;
mod items;

#[dojo::contract]
mod blobert_actions {
    use starknet::ContractAddress;
    use token::components::token::{erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait}};
    use blob_arena::collections::{
        interface::ICollection,
        blobert::{
            external::{
                get_erc271_dispatcher, get_blobert_dispatcher, IBlobertDispatcher,
                IBlobertDispatcherTrait, TokenTrait
            },
            items::BlobertItemsTrait
        },
    };
    #[abi(embed_v0)]
    impl ICollectionImpl of ICollection<ContractState> {
        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            let dispatcher = get_erc271_dispatcher();
            IERC721DispatcherTrait::owner_of(dispatcher, token_id)
        }

        fn get_items(self: @ContractState, token_id: u256) -> Span<u128> {
            let world = self.world();
            let dispatcher = get_blobert_dispatcher();
            let blobert_trait: TokenTrait = dispatcher.traits(token_id);
            let (background, armour, jewelry, mask, weapon) = world.get_item_ids(blobert_trait);
            array![background, armour, jewelry, mask, weapon].span()
        }
    }
}
