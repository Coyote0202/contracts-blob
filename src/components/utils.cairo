use core::{integer::BoundedInt, num::traits::{Zero, One}, fmt::{Display, Formatter, Error}};

trait IdTrait<T> {
    fn id(self: @T) -> u128;
}

trait IdsTrait<T> {
    fn ids(self: Array<T>) -> Array<u128>;
}

impl TIdsImpl<T, +IdTrait<T>, +Drop<T>> of IdsTrait<T> {
    fn ids(self: Array<T>) -> Array<u128> {
        let mut ids: Array<u128> = ArrayTrait::new();
        let (len, mut n) = (self.len(), 0_usize);
        while (n < len) {
            ids.append(self.at(n).id());
            n += 1;
        };
        ids
    }
}


#[derive(Copy, Drop, Print, Serde, PartialEq)]
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


struct ABT<T> {
    a: T,
    b: T,
}

impl ABTDropImpl<T, +Drop<T>> of Drop<ABT<T>>;
impl ABTCopyImpl<T, +Copy<T>> of Copy<ABT<T>>;

impl SABTIntoTuple<T, +Drop<T>, +Copy<T>> of Into<@ABT<T>, (T, T)> {
    fn into(self: @ABT<T>) -> (T, T) {
        ((*self).a, (*self).b)
    }
}

impl ABTIntoTuple<T, +Drop<T>,> of Into<ABT<T>, (T, T)> {
    fn into(self: ABT<T>) -> (T, T) {
        (self.a, self.b)
    }
}

impl ABTSerdeImpl<T, +Serde<T>, +Drop<T>> of Serde<ABT<T>> {
    fn serialize(self: @ABT<T>, ref output: Array<felt252>) {
        self.a.serialize(ref output);
        self.b.serialize(ref output);
    }
    fn deserialize(ref serialized: Span<felt252>) -> Option<ABT<T>> {
        Option::Some(
            ABTTrait::<
                T
            >::new(Serde::deserialize(ref serialized)?, Serde::deserialize(ref serialized)?)
        )
    }
}

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

#[derive(Copy, Drop, Print, Serde, PartialEq)]
enum Winner {
    A,
    B,
    Draw
}
#[derive(Copy, Drop, Print, Serde, PartialEq)]
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

impl DisplayImplT<T, +Into<T, ByteArray>, +Copy<T>> of Display<T> {
    fn fmt(self: @T, ref f: Formatter) -> Result<(), Error> {
        let str: ByteArray = (*self).into();
        f.buffer.append(@str);
        Result::Ok(())
    }
}
