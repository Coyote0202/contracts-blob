use core::{integer::BoundedInt, num::traits::{Zero, One}, fmt::{Display, Formatter, Error}};

trait IdTrait<T> {
    fn id(self: T) -> u128;
}

trait IdsTrait<T> {
    fn ids(self: Span<T>) -> Span<u128>;
}

impl TIdsImpl<T, +IdTrait<T>, +Drop<T>, +Copy<T>> of IdsTrait<T> {
    fn ids(self: Span<T>) -> Span<u128> {
        let mut ids: Array<u128> = ArrayTrait::new();
        let (len, mut n) = (self.len(), 0_usize);
        while (n < len) {
            ids.append((*self.at(n)).id());
            n += 1;
        };
        ids.span()
    }
}


#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum AB {
    A,
    B,
}

impl ABIntoByteArray of Into<AB, ByteArray> {
    fn into(self: AB) -> ByteArray {
        match self {
            AB::A => "A",
            AB::B => "B",
        }
    }
}

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
struct ABT<T> {
    a: T,
    b: T,
}

// impl ABTDropImpl<T, +Drop<T>, -Drop<ABT<T>>> of Drop<ABT<T>>;
// impl ABTCopyImpl<T, +Copy<T>> of Copy<ABT<T>>;

impl SpanTryIntoABT<T, +Drop<T>, +Copy<T>> of TryInto<Span<T>, ABT<T>> {
    fn try_into(self: Span<T>) -> Option<ABT<T>> {
        if self.len() == 2 {
            Option::Some(ABT { a: *self.at(0), b: *self.at(1) })
        } else {
            Option::None
        }
    }
}

impl TupleIntoABT<T, +Drop<T>,> of Into<(T, T), ABT<T>> {
    fn into(self: (T, T)) -> ABT<T> {
        let (a, b) = self;
        ABT { a, b }
    }
}

impl ABTIntoTuple<T, +Drop<T>,> of Into<ABT<T>, (T, T)> {
    fn into(self: ABT<T>) -> (T, T) {
        (self.a, self.b)
    }
}

impl ABTIntoSpan<T, +Drop<T>> of Into<ABT<T>, Span<T>> {
    fn into(self: ABT<T>) -> Span<T> {
        array![self.a, self.b].span()
    }
}

// impl ABTSerdeImpl<T, +Serde<T>, +Drop<T>> of Serde<ABT<T>> {
//     fn serialize(self: @ABT<T>, ref output: Array<felt252>) {
//         self.a.serialize(ref output);
//         self.b.serialize(ref output);
//     }
//     fn deserialize(ref serialized: Span<felt252>) -> Option<ABT<T>> {
//         Option::Some(
//             ABTTrait::<
//                 T
//             >::new(Serde::deserialize(ref serialized)?, Serde::deserialize(ref serialized)?)
//         )
//     }
// }

#[generate_trait]
impl ABTImpl<T, +Drop<T>> of ABTTrait<T> {
    fn new(a: T, b: T) -> ABT<T> {
        ABT { a, b }
    }
    fn new_from_tuple(t: (T, T)) -> ABT<T> {
        let (a, b) = t;
        ABT { a, b }
    }
    fn get(self: ABT<T>, player: AB) -> T {
        match player {
            AB::A => self.a,
            AB::B => self.b,
        }
    }
    fn set(ref self: ABT<T>, ab: AB, value: T) {
        match ab {
            AB::A => { self.a = value },
            AB::B => { self.b = value },
        };
    }
}

#[generate_trait]
impl ABTOtherImpl<T, +PartialEq<T>, +Drop<T>> of ABTOtherTrait<T> {
    fn other(self: ABT<T>, value: T) -> T {
        if self.a == value {
            self.b
        } else if self.b == value {
            self.a
        } else {
            panic!("Value not found in ABT")
        }
    }
}

#[generate_trait]
impl ABTLogicImpl<T, +Zero<T>, +Drop<T>> of ABTLogicTrait<T> {
    fn is_neither_zero(self: @ABT<T>) -> bool {
        self.a.is_non_zero() && self.b.is_non_zero()
    }
}

impl ABTZeroImpl<T, +Zero<T>, +Drop<T>> of Zero<ABT<T>> {
    fn zero() -> ABT<T> {
        ABT { a: Zero::<T>::zero(), b: Zero::zero() }
    }
    fn is_zero(self: @ABT<T>) -> bool {
        self.a.is_zero() && self.b.is_zero()
    }
    fn is_non_zero(self: @ABT<T>) -> bool {
        !self.is_zero()
    }
}

#[derive(Copy, Drop, Serde, PartialEq)]
enum Winner {
    A,
    B,
    Draw
}
#[derive(Copy, Drop, Serde, PartialEq)]
enum Status {
    Running,
    Finished: Winner,
}

impl WinnerIntoAB of Into<Winner, AB> {
    fn into(self: Winner) -> AB {
        match self {
            Winner::A => AB::A,
            Winner::B => AB::B,
            Winner::Draw => panic!("Game is a draw"),
        }
    }
}

impl BoundedIntIntoAB<T, +Drop<T>, +BoundedInt<T>, +Zero<T>, +One<T>> of Into<T, AB> {
    fn into(self: T) -> AB {
        if self.is_zero() {
            AB::A
        } else if self.is_one() {
            AB::B
        } else {
            panic!("Invalid value for AB")
        }
    }
}

impl BitNotAB of BitNot<AB> {
    fn bitnot(a: AB) -> AB {
        match a {
            AB::A => AB::B,
            AB::B => AB::A,
        }
    }
}
impl NotAB of Not<AB> {
    fn not(a: AB) -> AB {
        match a {
            AB::A => AB::B,
            AB::B => AB::A,
        }
    }
}

#[generate_trait]
impl ABBoolImpl of ABBoolTrait {
    fn both_true(self: ABT<bool>) -> bool {
        self.a && self.b
    }
    fn reset(ref self: ABT<bool>) {
        self.a = false;
        self.b = false;
    }
}
// impl DisplayImplT<T, +Into<T, ByteArray>, +Copy<T>> of Display<T> {
//     fn fmt(self: @T, ref f: Formatter) -> Result<(), Error> {
//         let str: ByteArray = self.into();
//         f.buffer.append(@str);
//         Result::Ok(())
//     }
// }


