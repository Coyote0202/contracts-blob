use blob_arena::models::Target;

#[derive(Drop, Serde, Introspect)]
enum AttackOutcomes {
    Failed,
    Stunned,
    Miss,
    Hit,
}

#[dojo::model]
#[dojo::event]
#[derive(Drop, Serde)]
struct AttackResult {
    #[key]
    combatant_id: felt252,
    #[key]
    round: u32,
    target: felt252,
    result: AttackOutcomes,
}


#[dojo::model]
#[dojo::event]
#[derive(Drop, Serde, Copy, PartialEq, Introspect)]
struct DamageResult {
    #[key]
    combatant_id: felt252,
    #[key]
    round: u32,
    #[key]
    move: u8,
    target: Target,
    damage: u8,
    critical: bool,
}
