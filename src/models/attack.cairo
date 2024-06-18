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
struct AvailableAttack {
    #[key]
    combat_id: u128,
    #[key]
    combatant: u128,
    #[key]
    attack: u128,
    available: bool,
    last_used: u32,
}

