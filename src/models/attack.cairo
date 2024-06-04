use blob_arena::components::{stats::Stats};

#[dojo::model]
#[derive(Drop, Serde, Clone)]
struct Attack {
    #[key]
    id: u128,
    damage: u8,
    speed: u8,
    accuracy: u8,
    critical: u8,
    stun: u8,
    cooldown: u8,
}

#[dojo::model]
#[derive(Drop, Serde)]
struct Cooldown {
    #[key]
    combat_id: u128,
    #[key]
    combatant: u8,
    #[key]
    attack: u8,
    last_use: u32,
}

struct Item {
    #[key]
    id: u128,
    name: ByteArray,
    stats: Stats,
    attacks: Array<Attack>,
}
