#[dojo::model]
#[derive(Drop, Serde)]
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

