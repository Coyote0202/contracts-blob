use starknet::{ContractAddress, class_hash::class_hash_const};

#[derive(Copy, Drop, Serde)]
enum WhitelistTier {
    One,
    Two,
    Three,
    Four
}

#[derive(Copy, Drop, Serde, Hash, PartialEq)]
struct Seed {
    background: u8,
    armour: u8,
    jewelry: u8,
    mask: u8,
    weapon: u8,
}

#[derive(Copy, Drop, Serde, PartialEq)]
enum TokenTrait {
    // regular tokens are identified by seed
    Regular: Seed,
    // custom tokens are indentified by index
    Custom: u8
}

#[derive(Copy, Drop, Serde, PartialEq)]
struct Supply {
    total_nft: u16,
    custom_nft: u8
}

#[derive(Copy, Drop, Serde, PartialEq)]
struct MintStartTime {
    regular: u64,
    whitelist: u64
}

#[starknet::interface]
trait IBlobert<TContractState> {
    // contract state read
    fn supply(self: @TContractState) -> Supply;
    fn max_supply(self: @TContractState) -> u16;
    fn whitelist_mint_count(self: @TContractState, address: ContractAddress) -> u8;
    fn regular_mint_count(self: @TContractState, address: ContractAddress) -> u8;
    fn content_uri(self: @TContractState, token_id: u256) -> ByteArray;
    fn traits(self: @TContractState, token_id: u256) -> TokenTrait;
    fn svg_image(self: @TContractState, token_id: u256) -> ByteArray;

    fn seeder(self: @TContractState) -> ContractAddress;
    fn descriptor_regular(self: @TContractState) -> ContractAddress;
    fn descriptor_custom(self: @TContractState) -> ContractAddress;
    fn mint_time(self: @TContractState) -> MintStartTime;


    // contract state write
    fn mint(ref self: TContractState, recipient: ContractAddress) -> u256;
    fn mint_whitelist(
        ref self: TContractState,
        recipient: ContractAddress,
        merkle_proof: Span<felt252>,
        whitelist_tier: WhitelistTier
    ) -> u256;
    fn owner_assign_custom(ref self: TContractState, recipients: Span<ContractAddress>);
    fn owner_change_descriptor_regular(ref self: TContractState, descriptor: ContractAddress);
    fn owner_change_descriptor_custom(ref self: TContractState, descriptor: ContractAddress);
}
