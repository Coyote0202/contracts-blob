use core::option::OptionTrait;
use core::fmt::{Display, Formatter, Error};
use blob_arena::core::{SaturatingAdd, SaturatingSub};

#[derive(Copy, Drop, Serde, PartialEq, Introspect, Default)]
struct TStats<T> {
    attack: T,
    defense: T,
    speed: T,
    dexterity: T,
}

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum StatTypes {
    Attack,
    Defense,
    Speed,
    Dexterity,
}


type Stats = TStats<u8>;

impl TIntoTStats<T, +Copy<T>> of Into<T, TStats<T>> {
    fn into(self: T) -> TStats<T> {
        TStats { attack: self, defense: self, speed: self, dexterity: self, }
    }
}


#[generate_trait]
impl TStatsImpl<T, +Drop<T>, +Copy<T>> of TStatsTrait<T> {
    fn get_stat(self: @TStats<T>, stat: StatTypes) -> T {
        match stat {
            StatTypes::Attack => *self.attack,
            StatTypes::Defense => *self.defense,
            StatTypes::Speed => *self.speed,
            StatTypes::Dexterity => *self.dexterity,
        }
    }

    fn set_stat(ref self: TStats<T>, stat: StatTypes, value: T) {
        match stat {
            StatTypes::Attack => { self.attack = value },
            StatTypes::Defense => { self.defense = value },
            StatTypes::Speed => { self.speed = value },
            StatTypes::Dexterity => { self.dexterity = value },
        }
    }
}

impl TStatsAdd<T, +Add<T>, +Drop<T>> of Add<TStats<T>> {
    fn add(lhs: TStats<T>, rhs: TStats<T>) -> TStats<T> {
        TStats {
            attack: lhs.attack + rhs.attack,
            defense: lhs.defense + rhs.defense,
            speed: lhs.speed + rhs.speed,
            dexterity: lhs.dexterity + rhs.dexterity,
        }
    }
}


impl TStatsSaturatingSub<T, +SaturatingSub<T>, +Drop<T>> of SaturatingSub<TStats<T>> {
    fn saturating_sub(self: TStats<T>, other: TStats<T>) -> TStats<T> {
        TStats {
            attack: self.attack.saturating_sub(other.attack),
            defense: self.defense.saturating_sub(other.defense),
            speed: self.speed.saturating_sub(other.speed),
            dexterity: self.dexterity.saturating_sub(other.dexterity),
        }
    }
}

impl TSaturatingAdd<T, +SaturatingAdd<T>, +Drop<T>> of SaturatingAdd<TStats<T>> {
    fn saturating_add(self: TStats<T>, other: TStats<T>) -> TStats<T> {
        TStats {
            attack: self.attack.saturating_add(other.attack),
            defense: self.defense.saturating_add(other.defense),
            speed: self.speed.saturating_add(other.speed),
            dexterity: self.dexterity.saturating_add(other.dexterity),
        }
    }
}


impl TStatsSub<T, +Sub<T>, +Drop<T>> of Sub<TStats<T>> {
    fn sub(lhs: TStats<T>, rhs: TStats<T>) -> TStats<T> {
        return TStats {
            attack: lhs.attack - rhs.attack,
            defense: lhs.defense - rhs.defense,
            speed: lhs.speed - rhs.speed,
            dexterity: lhs.dexterity - rhs.dexterity,
        };
    }
}

impl TStatsMul<T, +Mul<T>, +Drop<T>> of Mul<TStats<T>> {
    fn mul(lhs: TStats<T>, rhs: TStats<T>) -> TStats<T> {
        return TStats {
            attack: lhs.attack * rhs.attack,
            defense: lhs.defense * rhs.defense,
            speed: lhs.speed * rhs.speed,
            dexterity: lhs.dexterity * rhs.dexterity,
        };
    }
}

impl TStatsDiv<T, +Div<T>, +Drop<T>> of Div<TStats<T>> {
    fn div(lhs: TStats<T>, rhs: TStats<T>) -> TStats<T> {
        return TStats {
            attack: lhs.attack / rhs.attack,
            defense: lhs.defense / rhs.defense,
            speed: lhs.speed / rhs.speed,
            dexterity: lhs.dexterity / rhs.dexterity,
        };
    }
}
