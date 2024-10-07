use SaturatingAdd;
use core::option::OptionTrait;
use core::fmt::{Display, Formatter, Error};
use core::num::traits::{SaturatingAdd, SaturatingSub};

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
struct TStats<T> {
    attack: T,
    defense: T,
    speed: T,
    strength: T,
}


type Stats = TStats<u8>;

impl TIntoTStats<T, +Copy<T>> of Into<T, TStats<T>> {
    fn into(self: T) -> TStats<T> {
        TStats { attack: self, defense: self, speed: self, strength: self, }
    }
}

impl TStatsAdd<T, +Add<T>, +Drop<T>> of Add<TStats<T>> {
    fn add(lhs: TStats<T>, rhs: TStats<T>) -> TStats<T> {
        let a: i8 = 127;
        let b: i8 = -127;

        let c = a.saturating_sub(b);
        TStats {
            attack: lhs.attack + rhs.attack,
            defense: lhs.defense + rhs.defense,
            speed: lhs.speed + rhs.speed,
            strength: lhs.strength + rhs.strength,
        }
    }
}

impl TStatsSubBounded<T, +SubBounded<T>, +Drop<T>> of SubBounded<TStats<T>> {
    fn sub_bounded(self: TStats<T>, rhs: TStats<T>) -> TStats<T> {
        return TStats {
            attack: self.attack.sub_bounded(rhs.attack),
            defense: self.defense.sub_bounded(rhs.defense),
            speed: self.speed.sub_bounded(rhs.speed),
            strength: self.strength.sub_bounded(rhs.strength),
        };
    }

    fn subeq_bounded(ref self: TStats<T>, rhs: TStats<T>) {
        self = self.sub_bounded(rhs)
    }
}

impl TStatsAddBounded<T, +AddBounded<T>, +Drop<T>> of AddBounded<TStats<T>> {
    fn add_bounded(self: TStats<T>, rhs: TStats<T>) -> TStats<T> {
        return TStats {
            attack: self.attack.add_bounded(rhs.attack),
            defense: self.defense.add_bounded(rhs.defense),
            speed: self.speed.add_bounded(rhs.speed),
            strength: self.strength.add_bounded(rhs.strength),
        };
    }

    fn addeq_bounded(ref self: TStats<T>, rhs: TStats<T>) {
        self = self.add_bounded(rhs)
    }
}

impl TStatsSub<T, +Sub<T>, +Drop<T>> of Sub<TStats<T>> {
    fn sub(lhs: TStats<T>, rhs: TStats<T>) -> TStats<T> {
        return TStats {
            attack: lhs.attack - rhs.attack,
            defense: lhs.defense - rhs.defense,
            speed: lhs.speed - rhs.speed,
            strength: lhs.strength - rhs.strength,
        };
    }
}

impl TStatsMul<T, +Mul<T>, +Drop<T>> of Mul<TStats<T>> {
    fn mul(lhs: TStats<T>, rhs: TStats<T>) -> TStats<T> {
        return TStats {
            attack: lhs.attack * rhs.attack,
            defense: lhs.defense * rhs.defense,
            speed: lhs.speed * rhs.speed,
            strength: lhs.strength * rhs.strength,
        };
    }
}

impl TStatsDiv<T, +Div<T>, +Drop<T>> of Div<TStats<T>> {
    fn div(lhs: TStats<T>, rhs: TStats<T>) -> TStats<T> {
        return TStats {
            attack: lhs.attack / rhs.attack,
            defense: lhs.defense / rhs.defense,
            speed: lhs.speed / rhs.speed,
            strength: lhs.strength / rhs.strength,
        };
    }
}
