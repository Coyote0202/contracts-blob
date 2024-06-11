use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use blob_arena::models::CommitmentModel;

#[generate_trait]
impl CommitmentImpl of CommitReveal {
    fn _get_commitment(self: IWorldDispatcher, id: felt252) -> felt252 {
        get!(self, id, CommitmentModel).commitment
    }
    fn _set_commitment(self: IWorldDispatcher, id: felt252, commitment: felt252) {
        set!(self, CommitmentModel { id, commitment });
    }
    fn get_commitment<T, +Into<T, felt252>>(self: IWorldDispatcher, obj: T) -> felt252 {
        self._get_commitment(obj.into())
    }
    fn set_commitment<T, +Into<T, felt252>>(self: IWorldDispatcher, obj: T, commitment: felt252) {
        self._set_commitment(obj.into(), commitment)
    }
}

