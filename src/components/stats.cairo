use core::option::OptionTrait;
use core::fmt::{Display, Formatter, Error};
use blob_arena::core::{SaturatingAdd, SaturatingSub};

#[derive(Copy, Drop, Serde, PartialEq, Introspect, Default)]
struct TStats<T> {
    attack: T,
    vitality: T,
    dexterity: T,
    luck: T,
}

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum StatTypes {
    Attack,
    Vitality,
    Dexterity,
    Luck,
}


type Stats = TStats<u8>;

impl TIntoTStats<T, +Copy<T>> of Into<T, TStats<T>> {
    fn into(self: T) -> TStats<T> {
        TStats { attack: self, vitality: self, dexterity: self, luck: self, }
    }
}


#[generate_trait]
impl TStatsImpl<T, +Drop<T>, +Copy<T>> of TStatsTrait<T> {
    fn get_stat(self: @TStats<T>, stat: StatTypes) -> T {
        match stat {
            StatTypes::Attack => *self.attack,
            StatTypes::Vitality => *self.vitality,
            StatTypes::Dexterity => *self.dexterity,
            StatTypes::Luck => *self.luck,
        }
    }

    fn set_stat(ref self: TStats<T>, stat: StatTypes, value: T) {
        match stat {
            StatTypes::Attack => { self.attack = value },
            StatTypes::Vitality => { self.vitality = value },
            StatTypes::Dexterity => { self.dexterity = value },
            StatTypes::Luck => { self.luck = value },
        }
    }
}

impl TStatsAdd<T, +Add<T>, +Drop<T>> of Add<TStats<T>> {
    fn add(lhs: TStats<T>, rhs: TStats<T>) -> TStats<T> {
        TStats {
            attack: lhs.attack + rhs.attack,
            vitality: lhs.vitality + rhs.vitality,
            dexterity: lhs.dexterity + rhs.dexterity,
            luck: lhs.luck + rhs.luck,
        }
    }
}


impl TStatsSaturatingSub<T, +SaturatingSub<T>, +Drop<T>> of SaturatingSub<TStats<T>> {
    fn saturating_sub(self: TStats<T>, other: TStats<T>) -> TStats<T> {
        TStats {
            attack: self.attack.saturating_sub(other.attack),
            vitality: self.vitality.saturating_sub(other.vitality),
            dexterity: self.dexterity.saturating_sub(other.dexterity),
            luck: self.luck.saturating_sub(other.luck),
        }
    }
}

impl TSaturatingAdd<T, +SaturatingAdd<T>, +Drop<T>> of SaturatingAdd<TStats<T>> {
    fn saturating_add(self: TStats<T>, other: TStats<T>) -> TStats<T> {
        TStats {
            attack: self.attack.saturating_add(other.attack),
            vitality: self.vitality.saturating_add(other.vitality),
            dexterity: self.dexterity.saturating_add(other.dexterity),
            luck: self.luck.saturating_add(other.luck),
        }
    }
}


impl TStatsSub<T, +Sub<T>, +Drop<T>> of Sub<TStats<T>> {
    fn sub(lhs: TStats<T>, rhs: TStats<T>) -> TStats<T> {
        return TStats {
            attack: lhs.attack - rhs.attack,
            vitality: lhs.vitality - rhs.vitality,
            dexterity: lhs.dexterity - rhs.dexterity,
            luck: lhs.luck - rhs.luck,
        };
    }
}

impl TStatsMul<T, +Mul<T>, +Drop<T>> of Mul<TStats<T>> {
    fn mul(lhs: TStats<T>, rhs: TStats<T>) -> TStats<T> {
        return TStats {
            attack: lhs.attack * rhs.attack,
            vitality: lhs.vitality * rhs.vitality,
            dexterity: lhs.dexterity * rhs.dexterity,
            luck: lhs.luck * rhs.luck,
        };
    }
}

impl TStatsDiv<T, +Div<T>, +Drop<T>> of Div<TStats<T>> {
    fn div(lhs: TStats<T>, rhs: TStats<T>) -> TStats<T> {
        return TStats {
            attack: lhs.attack / rhs.attack,
            vitality: lhs.vitality / rhs.vitality,
            dexterity: lhs.dexterity / rhs.dexterity,
            luck: lhs.luck / rhs.luck,
        };
    }
}
