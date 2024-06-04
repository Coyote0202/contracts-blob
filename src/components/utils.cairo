use core::fmt::{Display, Formatter, Error};

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
