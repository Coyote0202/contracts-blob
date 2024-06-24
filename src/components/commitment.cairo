use core::{poseidon::{HashState}, hash::{Hash}};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use blob_arena::{models::CommitmentModel, utils::hash_value};

#[generate_trait]
impl CommitmentImpl of Commitment {
    fn get_commitment(self: @IWorldDispatcher, id: felt252) -> felt252 {
        get!((*self), id, CommitmentModel).commitment
    }
    fn set_commitment(self: IWorldDispatcher, id: felt252, commitment: felt252) {
        set!(self, CommitmentModel { id, commitment });
    }
    fn clear_commitment(self: IWorldDispatcher, id: felt252) {
        self.set_commitment(id, 0);
    }
    fn check_commitment_set(self: @IWorldDispatcher, id: felt252) -> bool {
        self.get_commitment(id).is_non_zero()
    }
    fn check_commitment_unset(self: @IWorldDispatcher, id: felt252) -> bool {
        self.get_commitment(id).is_zero()
    }
    fn check_commitments_set(self: @IWorldDispatcher, ids: Span<felt252>) -> bool {
        let (mut n, len) = (0, ids.len());
        let mut set = true;
        while n < len {
            if self.check_commitment_unset(*ids.at(n)) {
                set = false;
                break;
            }
            n += 1;
        };
        set
    }
    fn check_commitments_set_with<T, +Hash<T, HashState>, +Drop<T>, +Copy<T>>(
        self: @IWorldDispatcher, values: Span<T>
    ) -> bool {
        let (mut n, len) = (0, values.len());
        let mut set = true;
        while n < len {
            if self.check_commitment_set_with(*(values.at(n))) {
                set = false;
                break;
            }
            n += 1;
        };
        set
    }
    fn clear_commitments(self: IWorldDispatcher, ids: Span<felt252>) {
        let (mut n, len) = (0, ids.len());
        while n < len {
            self.clear_commitment(*ids.at(n));
            n += 1;
        };
    }
    fn clear_commitments_with<T, +Hash<T, HashState>, +Drop<T>, +Copy<T>>(
        self: IWorldDispatcher, values: Span<T>
    ) {
        let (mut n, len) = (0, values.len());
        while n < len {
            self.clear_commitment_with(*(values.at(n)));
            n += 1;
        };
    }

    fn set_new_commitment(self: IWorldDispatcher, id: felt252, hash: felt252) {
        assert(!self.check_commitment_set(id), 'Commitment already set');
        self.set_commitment(id, hash);
    }

    fn get_commitment_with<T, +Hash<T, HashState>, +Drop<T>>(
        self: @IWorldDispatcher, value: T
    ) -> felt252 {
        self.get_commitment(hash_value(value))
    }
    fn set_commitment_with<T, +Hash<T, HashState>, +Drop<T>>(
        self: IWorldDispatcher, value: T, commitment: felt252
    ) {
        self.set_commitment(hash_value(value), commitment)
    }
    fn clear_commitment_with<T, +Hash<T, HashState>, +Drop<T>>(self: IWorldDispatcher, value: T) {
        self.clear_commitment(hash_value(value));
    }
    fn check_commitment_set_with<T, +Hash<T, HashState>, +Drop<T>>(
        self: @IWorldDispatcher, value: T
    ) -> bool {
        self.check_commitment_set(hash_value(value))
    }
    fn check_commitment_unset_with<T, +Hash<T, HashState>, +Drop<T>>(
        self: @IWorldDispatcher, value: T
    ) -> bool {
        !self.check_commitment_set_with(value)
    }
    fn set_new_commitment_with<T, +Hash<T, HashState>, +Drop<T>>(
        self: IWorldDispatcher, value: T, hash: felt252
    ) {
        self.set_new_commitment(hash_value(value), hash);
    }
}

