use blob_arena::components::stats::TStats;
use integer::I8Serde;

type Stats = TStats<i8>;

#[derive(Drop, Serde, Copy, PartialEq, Introspect)]
enum Affect {
    Stats: Stats,
    Damage: Damage,
    Stun: u8,
    Health: i16,
}

#[derive(Drop, Serde, Copy, PartialEq, Introspect)]
struct Effect {
    target: Target,
    affect: Affect,
}

#[derive(Drop, Serde, Copy, PartialEq)]
struct Damage {
    critical: u8,
    damage: i16,
}

#[derive(Drop, Serde, Copy, PartialEq, Introspect)]
enum Target {
    Player,
    Opponent,
}

#[derive(Drop, Serde, Copy, PartialEq, Introspect)]
enum Direction {
    Increase,
    Decrease,
}


#[dojo::model]
#[derive(Drop, Serde)]
struct Attack {
    #[key]
    id: u128,
    name: ByteArray,
    speed: u8,
    accuracy: u8,
    cooldown: u8,
    hit: Array<Effect>,
    miss: Array<Effect>,
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct AvailableAttack {
    #[key]
    combatant_id: u128,
    #[key]
    attack_id: u128,
    available: bool,
    last_used: u32,
}
