use core::array::ArrayTCloneImpl;
use blob_arena::components::{stats::Stats};

#[dojo::model]
#[derive(Drop, Serde, Copy)]
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
#[derive(Drop, Serde, Copy)]
struct AttackLastUse {
    #[key]
    combat_id: u128,
    #[key]
    combatant: u128,
    #[key]
    attack: u128,
    round: u32,
}

