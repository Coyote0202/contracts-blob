use core::{
    integer::BoundedInt, hash::{HashStateTrait, HashStateExTrait, Hash},
    poseidon::{PoseidonTrait, HashState}
};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use starknet::{ContractAddress, get_contract_address, get_caller_address, get_tx_info};
use blob_arena::core::Felt252BitAnd;

fn hash_value<T, +Hash<T, HashState>, +Drop<T>>(value: T) -> felt252 {
    PoseidonTrait::new().update_with(value).finalize()
}

fn felt252_to_uuid(value: felt252) -> u128 {
    (value & BoundedInt::<u128>::max().into()).try_into().unwrap()
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
