use starknet::ContractAddress;
use blob_arena::components::{stats::Stats};


#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct CombatantInfo {
    #[key]
    combat_id: u128,
    #[key]
    warrior_id: u128,
    player: ContractAddress,
}

#[dojo::model]
#[derive(Drop, Serde)]
struct CombatantAttributes {
    #[key]
    combat_id: u128,
    #[key]
    warrior_id: u128,
    stats: Stats,
    attacks: Array<u128>,
}

#[derive(Drop, Serde)]
#[dojo::model]
struct CombatantState {
    #[key]
    combat_id: u128,
    #[key]
    warrior_id: u128,
    health: u8,
    stun_chances: Array<u8>,
}
