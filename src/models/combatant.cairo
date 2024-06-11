use starknet::ContractAddress;
use blob_arena::components::{stats::Stats};


#[dojo::model]
#[derive(Drop, Serde)]
struct Combatant {
    #[key]
    combat_id: u128,
    #[key]
    warrior_id: u128,
    player: ContractAddress,
    attacks: Array<u128>,
    stats: Stats,
}

#[dojo::model]
#[derive(Drop, Serde)]
struct CombatantState {
    #[key]
    combat_id: u128,
    #[key]
    warrior_id: u128,
    health: u8,
    stun_chances: Array<u8>,
}
