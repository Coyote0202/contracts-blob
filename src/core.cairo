use core::integer::BoundedInt;

#[derive(Copy, Drop)]
type TTupleSize5<T> = (T, T, T, T, T);


trait LimitSub<T> {
    fn sub(self: T, other: T) -> T;
    fn subeq(ref self: T, other: T);
}

trait LimitAdd<T> {
    fn add(self: T, other: T) -> T;
    fn addeq(ref self: T, other: T);
}

impl TLimitSubImpl<T, +BoundedInt<T>, +Sub<T>, +PartialOrd<T>, +Copy<T>, +Drop<T>> of LimitSub<T> {
    fn sub(self: T, other: T) -> T {
        if other < self {
            self - other
        } else {
            BoundedInt::min()
        }
    }

    fn subeq(ref self: T, other: T) {
        self = self.sub(other)
    }
}

impl TLimitAddImpl<T, +BoundedInt<T>, +Add<T>, +PartialOrd<T>, +Copy<T>, +Drop<T>> of LimitAdd<T> {
    fn add(self: T, other: T) -> T {
        if self + other < BoundedInt::max() {
            self + other
        } else {
            BoundedInt::max()
        }
    }

    fn addeq(ref self: T, other: T) {
        self = self.add(other)
    }
}


impl Felt252BitAnd of BitAnd<felt252> {
    #[inline(always)]
    fn bitand(lhs: felt252, rhs: felt252) -> felt252 {
        (Into::<felt252, u256>::into(lhs) & rhs.into()).try_into().unwrap()
    }
}
// impl U8ArrayCopyImpl of Copy<Array<u8>>;
// impl U128ArrayCopyImpl of Copy<Array<u128>>;

