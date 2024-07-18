use starknet::ContractAddress;
use blob_arena::{components::{stats::Stats}};


#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct CombatantInfo {
    #[key]
    id: u128,
    combat_id: u128,
    player: ContractAddress,
    collection_address: ContractAddress,
    token_id: u256,
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct CombatantStats {
    #[key]
    id: u128,
    attack: u8,
    defense: u8,
    speed: u8,
    strength: u8,
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct CombatantState {
    #[key]
    id: u128,
    health: u8,
    stun_chance: u8
}


#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct PlannedAttack {
    #[key]
    id: u128,
    attack: u128,
    target: u128,
}
