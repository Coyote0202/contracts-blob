#[dojo::model]
#[derive(Drop, Serde)]
struct Attack {
    #[key]
    id: u128,
    name: ByteArray,
    damage: u8,
    speed: u8,
    accuracy: u8,
    critical: u8,
    stun: u8,
    cooldown: u8,
    heal: u8,
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