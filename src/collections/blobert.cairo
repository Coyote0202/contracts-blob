mod external;
mod items;
use dojo::world::{IWorldDispatcher};
use super::blobert::items::BlobertTrait;
use blob_arena::components::{stats::Stats, item::AttackInput};


#[dojo::interface]
trait IBlobertItems {
    fn set_seed_item_id(
        ref world: IWorldDispatcher, blobert_trait: BlobertTrait, trait_id: u8, item_id: u128
    );
    fn set_custom_item_id(
        ref world: IWorldDispatcher, blobert_trait: BlobertTrait, trait_id: u8, item_id: u128
    );
    fn new_seed_item_with_attacks(
        ref world: IWorldDispatcher,
        blobert_trait: BlobertTrait,
        trait_id: u8,
        item_name: ByteArray,
        stats: Stats,
        attacks: Array<AttackInput>
    );
    fn new_custom_item_with_attacks(
        ref world: IWorldDispatcher,
        blobert_trait: BlobertTrait,
        trait_id: u8,
        item_name: ByteArray,
        stats: Stats,
        attacks: Array<AttackInput>
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
                items::{BlobertItemsTrait, BlobertTrait, BlobertStatsTrait}
            },
        },
        components::{stats::Stats, item::{ItemTrait, AttackInput}}, world::{WorldTrait, Contract}
    };
    use super::IBlobertItems;

    #[generate_trait]
    impl PrivateImpl of PrivateTrait {
        fn get_blobert_traits(self: @IWorldDispatcher, token_id: u256) -> TokenTrait {
            let dispatcher = get_blobert_dispatcher();
            dispatcher.traits(token_id)
        }
    }

    #[abi(embed_v0)]
    impl ICollectionImpl of ICollection<ContractState> {
        fn get_owner(world: @IWorldDispatcher, token_id: u256) -> ContractAddress {
            let dispatcher = get_erc271_dispatcher();
            IERC721DispatcherTrait::owner_of(dispatcher, token_id)
        }
        fn get_health(world: @IWorldDispatcher, token_id: u256) -> u8 {
            let traits = world.get_blobert_traits(token_id);
            world.get_blobert_health(traits)
        }
        fn get_stats(world: @IWorldDispatcher, token_id: u256) -> Stats {
            let traits = world.get_blobert_traits(token_id);
            world.get_blobert_stats(traits)
        }
        fn has_attack(
            world: @IWorldDispatcher, token_id: u256, item_id: u128, attack_id: u128
        ) -> bool {
            let traits = world.get_blobert_traits(token_id);
            world.blobert_has_attack(traits, item_id, attack_id)
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
        fn new_seed_item_with_attacks(
            ref world: IWorldDispatcher,
            blobert_trait: BlobertTrait,
            trait_id: u8,
            item_name: ByteArray,
            stats: Stats,
            attacks: Array<AttackInput>
        ) {
            world.assert_caller_is_owner(get_contract_address());
            let item_id = world.create_new_item(item_name, stats);
            world.create_and_set_new_attacks(item_id, attacks);
            world.set_seed_item_id(blobert_trait, trait_id, item_id);
        }
        fn new_custom_item_with_attacks(
            ref world: IWorldDispatcher,
            blobert_trait: BlobertTrait,
            trait_id: u8,
            item_name: ByteArray,
            stats: Stats,
            attacks: Array<AttackInput>
        ) {
            world.assert_caller_is_owner(get_contract_address());
            let item_id = world.create_new_item(item_name, stats);
            world.create_and_set_new_attacks(item_id, attacks);
            world.set_custom_item_id(blobert_trait, trait_id, item_id);
        }
    }
}
