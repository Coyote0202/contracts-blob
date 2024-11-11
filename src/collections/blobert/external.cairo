use starknet::{ContractAddress, class_hash::class_hash_const};
use blob_arena::collections::interface::{ICollection, IERC721Dispatcher, IERC721DispatcherTrait};

// Sepolia
// const BLOBERT_CONTRACT_ADDRESS: felt252 =
//     0x032cb9f30629268612ffb6060e40dfc669849c7d72539dd23c80fe6578d0549d;

// Mainnet
const BLOBERT_CONTRACT_ADDRESS: felt252 =
    0x00539f522b29ae9251dbf7443c7a950cf260372e69efab3710a11bf17a9599f1;

#[derive(Copy, Drop, Serde)]
enum WhitelistTier {
    One,
    Two,
    Three,
    Four
}

#[derive(Copy, Drop, Serde, Hash, PartialEq, Introspect, Default)]
struct Seed {
    background: u8,
    armour: u8,
    jewelry: u8,
    mask: u8,
    weapon: u8,
}

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
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


fn get_blobert_dispatchers() -> (IERC721Dispatcher, IBlobertDispatcher) {
    let contract_address: ContractAddress = BLOBERT_CONTRACT_ADDRESS.try_into().unwrap();
    (IERC721Dispatcher { contract_address }, IBlobertDispatcher { contract_address })
}

fn get_erc271_dispatcher() -> IERC721Dispatcher {
    let contract_address: ContractAddress = BLOBERT_CONTRACT_ADDRESS.try_into().unwrap();
    IERC721Dispatcher { contract_address }
}

fn get_blobert_dispatcher() -> IBlobertDispatcher {
    let contract_address: ContractAddress = BLOBERT_CONTRACT_ADDRESS.try_into().unwrap();
    IBlobertDispatcher { contract_address }
}
