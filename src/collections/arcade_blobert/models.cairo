use starknet::ContractAddress;
use blob_arena::collections::blobert::external::Seed;

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct ArcadeBlobert {
    #[key]
    token_id: felt252,
    owner: ContractAddress,
    is_custom: bool,
    custom_id: u8,
    seed: Seed
}
