use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher};
use blob_arena::components::{stats::Stats};

#[dojo::interface]
trait ICollection {
    fn url(world: @IWorldDispatcher) -> ByteArray;
    fn owner(world: @IWorldDispatcher, token_id: u256) -> ContractAddress;
    fn get_health(world: @IWorldDispatcher, token_id: u256) -> u8;
    fn get_stats(world: @IWorldDispatcher, token_id: u256) -> Stats;
    fn get_speed(world: @IWorldDispatcher, token_id: u256, attack_id: u128) -> Span<u128>;
    fn has_attack(world: @IWorldDispatcher, token_id: u256, attack_id: u128, item_id: u128) -> bool;
}
fn get_collection_dispatcher(contract_address: ContractAddress) -> ICollectionDispatcher {
    ICollectionDispatcher { contract_address }
}
// #[dojo::interface]
// trait IAttack<TContractState> {
//     fn run_attack(self: TContractState, token_id: u256, attack_id: u128, calldata: ByteArray);
// }

// struct CollectionWorld {
//     world: IWorldDispatcher,
//     collection_address: ContractAddress,
// }
// #[generate_trait]
// impl CollectionImpl of CollectionTrait {
//     
//     fn new(self: @IWorldDispatcher, collection_address: ContractAddress) -> CollectionWorld {
//         CollectionWorld { world: *self, collection_address }
//     }
//     fn url(self: @CollectionWorld) -> ByteArray {
//         get_collection_dispatcher(*self.collection_address).url()
//     }

//     fn owner(self: @CollectionWorld, token_id: u256) -> ContractAddress {
//         get_collection_dispatcher(*self.collection_address).owner(token_id)
//     }

//     fn get_health(self: @CollectionWorld, token_id: u256) -> Span<u128> {
//         get_collection_dispatcher(*self.collection_address).get_health(token_id)
//     }

//     fn get_speed(self: @CollectionWorld, token_id: u256, attack_id: u128) -> Span<u128> {
//         get_collection_dispatcher(*self.collection_address).get_speed(token_id, attack_id)
//     }

//     fn has_attack(self: @CollectionWorld, token_id: u256, attack_id: u128) -> bool {
//         get_collection_dispatcher(*self.collection_address).has_attack(token_id, attack_id)
//     }
// }


