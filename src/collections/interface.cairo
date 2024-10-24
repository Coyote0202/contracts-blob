use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher};
use blob_arena::components::{stats::Stats};


#[dojo::interface]
trait IERC721 {
    fn balance_of(world: @IWorldDispatcher, account: ContractAddress) -> u256;
    fn owner_of(world: @IWorldDispatcher, token_id: u256) -> ContractAddress;
    fn safe_transfer_from(
        ref world: IWorldDispatcher,
        from: ContractAddress,
        to: ContractAddress,
        token_id: u256,
        data: Span<felt252>
    );
    fn transfer_from(
        ref world: IWorldDispatcher, from: ContractAddress, to: ContractAddress, token_id: u256
    );
    fn approve(ref world: IWorldDispatcher, to: ContractAddress, token_id: u256);
    fn set_approval_for_all(ref world: IWorldDispatcher, operator: ContractAddress, approved: bool);
    fn get_approved(world: @IWorldDispatcher, token_id: u256) -> ContractAddress;
    fn is_approved_for_all(
        world: @IWorldDispatcher, owner: ContractAddress, operator: ContractAddress
    ) -> bool;
    fn name(world: @IWorldDispatcher) -> felt252;
    fn symbol(world: @IWorldDispatcher) -> felt252;
    fn token_uri(world: @IWorldDispatcher, token_id: u256) -> felt252;
    fn balanceOf(world: @IWorldDispatcher, account: ContractAddress) -> u256;
    fn ownerOf(world: @IWorldDispatcher, tokenId: u256) -> ContractAddress;
    fn safeTransferFrom(
        ref world: IWorldDispatcher,
        from: ContractAddress,
        to: ContractAddress,
        tokenId: u256,
        data: Span<felt252>
    );
    fn transferFrom(
        ref world: IWorldDispatcher, from: ContractAddress, to: ContractAddress, tokenId: u256
    );
    fn setApprovalForAll(ref world: IWorldDispatcher, operator: ContractAddress, approved: bool);
    fn getApproved(world: @IWorldDispatcher, tokenId: u256) -> ContractAddress;
    fn isApprovedForAll(
        world: @IWorldDispatcher, owner: ContractAddress, operator: ContractAddress
    ) -> bool;
    fn tokenURI(world: @IWorldDispatcher, tokenId: u256) -> felt252;
}

#[dojo::interface]
trait ICollection {
    fn get_owner(world: @IWorldDispatcher, token_id: u256) -> ContractAddress;
    fn get_item_ids(world: @IWorldDispatcher, token_id: u256) -> Span<felt252>;
    fn get_health(world: @IWorldDispatcher, token_id: u256) -> u8;
    fn get_stats(world: @IWorldDispatcher, token_id: u256) -> Stats;
    fn has_attack(
        world: @IWorldDispatcher, token_id: u256, item_id: felt252, attack_id: felt252
    ) -> bool;
}
fn get_collection_dispatcher(contract_address: ContractAddress) -> ICollectionDispatcher {
    ICollectionDispatcher { contract_address }
}

