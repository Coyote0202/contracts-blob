use core::{
    num::traits::{Bounded, Zero, OverflowingSub, OverflowingAdd, OverflowingMul}, cmp::{min, max}
};

#[derive(Copy, Drop)]
type TTupleSize5<T> = (T, T, T, T, T);

trait BoundedT<T, S> {
    fn min() -> S;
    fn max() -> S;
}

impl BoundedTImpl<T, S, +Bounded<T>, +TryInto<T, S>> of BoundedT<T, S> {
    fn min() -> S {
        Bounded::<T>::MIN.try_into().unwrap()
    }

    fn max() -> S {
        Bounded::<T>::MAX.try_into().unwrap()
    }
}

pub trait SaturatingInto<T, S> {
    fn saturating_into(self: T) -> S;
}

pub trait SaturatingAdd<T> {
    /// Saturating addition. Computes `self + other`, saturating at the relevant high or low
    /// boundary of the type.
    fn saturating_add(self: T, other: T) -> T;
}

/// Performs subtraction that saturates at the numeric bounds instead of overflowing.
pub trait SaturatingSub<T> {
    /// Saturating subtraction. Computes `self - other`, saturating at the relevant high or low
    /// boundary of the type.
    fn saturating_sub(self: T, other: T) -> T;
}

/// Performs multiplication that saturates at the numeric bounds instead of overflowing.
pub trait SaturatingMul<T> {
    /// Saturating multiplication. Computes `self * other`, saturating at the relevant high or low
    /// boundary of the type.
    fn saturating_mul(self: T, other: T) -> T;
}

pub impl TSaturatingAdd<
    T, +Drop<T>, +Copy<T>, +OverflowingAdd<T>, +Bounded<T>, +Zero<T>, +PartialOrd<T>
> of SaturatingAdd<T> {
    fn saturating_add(self: T, other: T) -> T {
        let (result, overflow) = self.overflowing_add(other);
        match overflow {
            true => { if other < Zero::zero() {
                Bounded::MIN
            } else {
                Bounded::MAX
            } },
            false => result,
        }
    }
}

pub impl TSaturatingSub<
    T, +Drop<T>, +Copy<T>, +OverflowingSub<T>, +Bounded<T>, +Zero<T>, +PartialOrd<T>
> of SaturatingSub<T> {
    fn saturating_sub(self: T, other: T) -> T {
        let (result, overflow) = self.overflowing_sub(other);
        match overflow {
            true => { if other < Zero::zero() {
                Bounded::MAX
            } else {
                Bounded::MIN
            } },
            false => result,
        }
    }
}


pub impl TSaturatingMul<
    T, +Drop<T>, +Copy<T>, +OverflowingMul<T>, +Bounded<T>, +Zero<T>, +PartialOrd<T>
> of SaturatingMul<T> {
    fn saturating_mul(self: T, other: T) -> T {
        let (result, overflow) = self.overflowing_mul(other);
        match overflow {
            true => {
                if (self < Zero::zero()) == (other < Zero::zero()) {
                    Bounded::MAX
                } else {
                    Bounded::MIN
                }
            },
            false => result,
        }
    }
}

pub impl TSaturatingIntoS<
    T, S, +Drop<T>, +Copy<T>, +TryInto<T, S>, +Bounded<S>, +BoundedT<S, T>, +PartialOrd<T>, +Zero<T>
> of SaturatingInto<T, S> {
    fn saturating_into(self: T) -> S {
        match self.try_into() {
            Option::Some(value) => value,
            Option::None => { if self > Zero::zero() {
                Bounded::MAX
            } else {
                Bounded::MIN
            } }
        }
    }
}

impl Felt252BitAnd of BitAnd<felt252> {
    #[inline(always)]
    fn bitand(lhs: felt252, rhs: felt252) -> felt252 {
        (Into::<felt252, u256>::into(lhs) & rhs.into()).try_into().unwrap()
    }
}

fn in_range<T, +PartialOrd<T>, +Drop<T>, +Copy<T>>(min: T, max: T, value: T) -> T {
    max(min, min(max, value))
}
// impl U8ArrayCopyImpl of Copy<Array<u8>>;
// impl U128ArrayCopyImpl of Copy<Array<u128>>;


