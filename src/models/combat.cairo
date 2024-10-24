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

#[derive(Drop, Serde, Introspect)]
enum AttackOutcomes {
    Failed,
    Stunned,
    Miss: Array<EffectResult>,
    Hit: Array<EffectResult>,
}

#[derive(Drop, Serde, Copy, PartialEq, Introspect)]
enum AffectResult {
    Success,
    Damage: DamageResult,
}

#[derive(Drop, Serde, Copy, PartialEq, Introspect)]
struct EffectResult {
    target: Target,
    affect: AffectResult,
}

#[derive(Drop, Serde, Copy, PartialEq, Introspect)]
struct DamageResult {
    damage: u8,
    critical: bool,
}

#[dojo::model]
#[derive(Drop, Serde)]
struct Salts {
    #[key]
    id: felt252,
    salts: Array<felt252>
}

