mod external;
mod items;
use dojo::world::{IWorldDispatcher};
use super::blobert::items::BlobertTrait;

#[dojo::interface]
trait IBlobertItems {
    fn set_seed_item_id(
        ref world: IWorldDispatcher, blobert_trait: BlobertTrait, trait_id: u8, item_id: u128
    );
    fn set_custom_item_id(
        ref world: IWorldDispatcher, blobert_trait: BlobertTrait, trait_id: u8, item_id: u128
    );
}

#[dojo::contract]
mod blobert_actions {
    use starknet::{ContractAddress, get_contract_address};
    use token::components::token::{erc721::interface::{IERC721Dispatcher, IERC721DispatcherTrait}};
    use blob_arena::{
        collections::{
            interface::ICollection,
            blobert::{
                external::{
                    get_erc271_dispatcher, get_blobert_dispatcher, IBlobertDispatcher,
                    IBlobertDispatcherTrait, TokenTrait
                },
                items::{BlobertItemsTrait, BlobertTrait}
            },
        },
        world::{WorldTrait, Contract}
    };
    use super::IBlobertItems;
    #[abi(embed_v0)]
    impl ICollectionImpl of ICollection<ContractState> {
        fn owner(self: @ContractState, token_id: u256) -> ContractAddress {
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
    #[abi(embed_v0)]
    impl IBlobertItemsImpl of IBlobertItems<ContractState> {
        fn set_seed_item_id(
            ref world: IWorldDispatcher, blobert_trait: BlobertTrait, trait_id: u8, item_id: u128
        ) {
            world.assert_caller_is_owner(get_contract_address());
            world.set_seed_item_id(blobert_trait, trait_id, item_id);
        }
        fn set_custom_item_id(
            ref world: IWorldDispatcher, blobert_trait: BlobertTrait, trait_id: u8, item_id: u128
        ) {
            world.assert_caller_is_owner(get_contract_address());
            world.set_custom_item_id(blobert_trait, trait_id, item_id);
        }
    }
}
