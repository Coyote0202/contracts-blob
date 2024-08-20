use core::{
    num::traits::Bounded, hash::{HashStateTrait, HashStateExTrait, Hash},
    poseidon::{PoseidonTrait, HashState}
};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::{
    ContractAddress, get_contract_address, get_caller_address, get_tx_info, get_block_timestamp
};
use blob_arena::core::Felt252BitAnd;

fn hash_value<T, +Hash<T, HashState>, +Drop<T>>(value: T) -> felt252 {
    PoseidonTrait::new().update_with(value).finalize()
}

fn felt252_to_uuid(value: felt252) -> u128 {
    (value & Bounded::<u128>::MAX.into()).try_into().unwrap()
}

fn value_to_uuid<T, +Hash<T, HashState>, +Drop<T>>(value: T) -> u128 {
    felt252_to_uuid(hash_value(value))
}

fn uuid(world: IWorldDispatcher) -> u128 {
    let values = (
        dojo::world::IWorldDispatcherTrait::uuid(world), get_tx_info().unbox().transaction_hash
    );
    felt252_to_uuid(PoseidonTrait::new().update_with(values).finalize())
}


#[dojo::model]
#[derive(Drop, Serde)]
struct RandomSeed {
    #[key]
    key: bool,
    value: felt252,
}

#[generate_trait]
impl RandomnessImpl of RandomnessTrait {
    fn get_randomness(ref world: IWorldDispatcher) -> felt252 {
        let seed = get!(world, true, RandomSeed).value;
        let values = (get_block_timestamp(), get_tx_info().unbox().transaction_hash, seed);
        let value = hash_value(values);
        set!(world, RandomSeed { key: true, value });
        value
    }
}
