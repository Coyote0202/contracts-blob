use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

#[starknet::interface]
#[dojo::interface]
trait ICollection<TContractState> {
    fn owner_of(self: @TContractState, token_id: u256) -> ContractAddress;
    fn get_items(self: @TContractState, token_id: u256) -> Span<u128>;
}
// fn owner_of_erc721(contract_address: ContractAddress, token_id: u256) -> ContractAddress {
//     let erc721 = IERC721Dispatcher { contract_address };
//     erc721.owner_of(token_id)
// }

#[generate_trait]
impl CollectionImpl of CollectionTrait {
    fn owner_of(self: @ContractAddress, token_id: u256) -> ContractAddress {
        let dispatcher = ICollectionDispatcher { contract_address: *self };
        dispatcher.owner_of(token_id)
    }
    fn get_items(self: @ContractAddress, token_id: u256) -> Span<u128> {
        let dispatcher = ICollectionDispatcher { contract_address: *self };
        dispatcher.get_items(token_id)
    }
}

