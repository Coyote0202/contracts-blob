mod blobert;
mod mint;

#[dojo::interface]
trait IArcadeBlobert {
    fn mint(ref world: IWorldDispatcher) -> u256;
}

#[dojo::contract]
mod arcade_blobert_actions {
    use starknet::ContractAddress;
    use blob_arena::collections::{
        interface::ICollection, blobert::{items::BlobertItemsTrait},
        arcade_blobert::blobert::{ArcadeBlobert, ArcadeBlobertTrait}
    };


    #[abi(embed_v0)]
    impl ICollectionImpl of ICollection<ContractState> {
        fn owner_of(self: @ContractState, token_id: u256) -> ContractAddress {
            let world = self.world();
            world.get_owner(token_id)
        }

        fn get_items(self: @ContractState, token_id: u256) -> Span<u128> {
            let world = self.world();
            let blobert_trait = world.get_traits(token_id);
            let (background, armour, jewelry, mask, weapon) = world.get_item_ids(blobert_trait);
            array![background, armour, jewelry, mask, weapon].span()
        }
    }
}
