mod blobert;
mod mint;
use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher};
use blob_arena::collections::blobert::external::TokenTrait;

#[dojo::interface]
trait IArcadeBlobert<TContractState> {
    fn mint(ref world: IWorldDispatcher) -> u256;
    fn mint_with_traits(
        ref world: IWorldDispatcher, player: ContractAddress, traits: TokenTrait
    ) -> u256;
    fn traits(world: @IWorldDispatcher, token_id: u256) -> TokenTrait;
}

#[dojo::contract]
mod arcade_blobert_actions {
    use starknet::ContractAddress;
    use blob_arena::{
        collections::{
            interface::ICollection,
            blobert::{items::{BlobertItemsTrait, BlobertStatsTrait}, external::TokenTrait},
            arcade_blobert::{
                blobert::{ArcadeBlobert, ArcadeBlobertTrait}, mint::ArcadeBlobertMintTrait
            },
        },
        components::{stats::Stats}
    };
    use super::IArcadeBlobert;


    #[abi(embed_v0)]
    impl ICollectionImpl of ICollection<ContractState> {
        fn get_owner(world: @IWorldDispatcher, token_id: u256) -> ContractAddress {
            world.get_arcade_blobert_owner(token_id)
        }
        fn get_item_ids(world: @IWorldDispatcher, token_id: u256) -> Span<u128> {
            let traits = world.get_arcade_blobert_traits(token_id);
            world.get_blobert_item_ids(traits).span()
        }
        fn get_health(world: @IWorldDispatcher, token_id: u256) -> u8 {
            let traits = world.get_arcade_blobert_traits(token_id);
            world.get_blobert_health(traits)
        }
        fn get_stats(world: @IWorldDispatcher, token_id: u256) -> Stats {
            let traits = world.get_arcade_blobert_traits(token_id);
            world.get_blobert_stats(traits)
        }
        fn has_attack(
            world: @IWorldDispatcher, token_id: u256, item_id: u128, attack_id: u128
        ) -> bool {
            let traits = world.get_arcade_blobert_traits(token_id);
            world.blobert_has_attack(traits, item_id, attack_id)
        }
    }

    #[abi(embed_v0)]
    impl IArcadeBlobertImpl of IArcadeBlobert<ContractState> {
        fn mint(ref world: IWorldDispatcher) -> u256 {
            world.mint_blobert()
        }
        fn mint_with_traits(
            ref world: IWorldDispatcher, player: ContractAddress, traits: TokenTrait
        ) -> u256 {
            world.mint_blobert_with_traits(player, traits)
        }
        fn traits(world: @IWorldDispatcher, token_id: u256) -> TokenTrait {
            world.get_arcade_blobert_traits(token_id)
        }
    }
}
