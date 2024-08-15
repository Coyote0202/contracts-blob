#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum Phase {
    Setup,
    Commit,
    Reveal,
    Ended: u128,
}

#[dojo::model]
#[derive(Drop, Serde, Copy, Introspect)]
struct CombatState {
    #[key]
    id: u128,
    round: u32,
    phase: Phase,
    block_number: u64,
}

#[derive(Drop, Serde, Copy, Introspect)]
struct AttackHit {
    damage: u8,
    stun: u8,
    critical: bool,
}

#[derive(Drop, Serde, Copy, Introspect)]
enum AttackEffect {
    Failed,
    Stunned,
    Miss,
    Hit: AttackHit,
}

#[derive(Drop, Serde, Copy, Introspect)]
#[dojo::model]
#[dojo::event]
pub struct AttackResult {
    #[key]
    pub combatant_id: u128,
    #[key]
    pub round: u32,
    pub attack_id: u128,
    pub target: u128,
    pub effect: AttackEffect,
}

#[dojo::model]
#[derive(Drop, Serde)]
struct Salts {
    #[key]
    id: u128,
    salts: Array<felt252>
}

