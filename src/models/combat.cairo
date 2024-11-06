use blob_arena::models::Target;

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum Phase {
    Setup,
    Commit,
    Reveal,
    Ended: felt252,
}

#[dojo::model]
#[derive(Drop, Serde, Copy, Introspect)]
struct CombatState {
    #[key]
    id: felt252,
    round: u32,
    phase: Phase,
    block_number: u64,
}

#[dojo::model]
#[derive(Drop, Serde)]
struct Salts {
    #[key]
    id: felt252,
    salts: Array<felt252>
}

