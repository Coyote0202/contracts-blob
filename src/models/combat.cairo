#[derive(Copy, Drop, Print, Serde, SerdeLen, PartialEq, Introspect)]
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

#[dojo::event]
#[derive(Drop, Serde, Copy)]
struct AttackResult {
    #[key]
    combatant_id: u128,
    #[key]
    round: u32,
    attack: u128,
    target: u128,
    effect: AttackEffect,
}

#[dojo::model]
#[derive(Drop, Serde)]
struct Salts {
    #[key]
    id: u128,
    salts: Array<felt252>
}

