use core::num::traits::{Bounded, Zero};

#[derive(Copy, Drop)]
type TTupleSize5<T> = (T, T, T, T, T);


impl Felt252BitAnd of BitAnd<felt252> {
    #[inline(always)]
    fn bitand(lhs: felt252, rhs: felt252) -> felt252 {
        (Into::<felt252, u256>::into(lhs) & rhs.into()).try_into().unwrap()
    }
}
// impl U8ArrayCopyImpl of Copy<Array<u8>>;
// impl U128ArrayCopyImpl of Copy<Array<u128>>;


