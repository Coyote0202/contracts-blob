use core::{
    num::traits::Bounded, hash::{HashStateTrait, HashStateExTrait, Hash},
    poseidon::{PoseidonTrait, HashState, poseidon_hash_span}
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

fn uuid(world: IWorldDispatcher) -> felt252 {
    let values = (
        dojo::world::IWorldDispatcherTrait::uuid(world), get_tx_info().unbox().transaction_hash
    );
    hash_value(values)
}

impl ArrayHash<
    T, S, +HashStateTrait<S>, +Hash<T, S>, +Drop<Array<T>>, +Drop<S>
> of Hash<Array<T>, S> {
    fn update_state(mut state: S, mut value: Array<T>) -> S {
        loop {
            match value.pop_front() {
                Option::Some(v) => { state = Hash::update_state(state, v); },
                Option::None => { break; },
            }
        };
        state
    }
}

fn array_to_hash_state<T, +Hash<T, HashState>, +Drop<Array<T>>,>(arr: Array<T>) -> HashState {
    Hash::update_state(PoseidonTrait::new(), arr)
}

fn make_hash_state<T, +Hash<T, HashState>, +Drop<T>>(value: T) -> HashState {
    PoseidonTrait::new().update_with(value)
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

trait ToHash<T> {
    fn update_to(self: @HashState, value: T) -> felt252;
}

fn felt252_to_u128(value: felt252) -> u128 {
    Into::<felt252, u256>::into(value).low
}

impl TToHashImpl<T, +Hash<T, HashState>, +Drop<T>> of ToHash<T> {
    fn update_to(self: @HashState, value: T) -> felt252 {
        (*self).update_with(value).finalize()
    }
}

trait UpdateHashToU128 {
    fn to_u128(self: HashState) -> u128;
    fn update_to_u128<T, +Hash<T, HashState>>(self: HashState, value: T) -> u128;
}

impl HashToU128Impl of UpdateHashToU128 {
    fn to_u128(self: HashState) -> u128 {
        felt252_to_u128(self.finalize())
    }
    fn update_to_u128<T, +Hash<T, HashState>>(self: HashState, value: T) -> u128 {
        Self::to_u128(Hash::update_state(self, value))
    }
}

