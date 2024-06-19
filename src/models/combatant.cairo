use starknet::ContractAddress;
use blob_arena::{components::{stats::Stats}, core::{U8ArrayCopyImpl, U128ArrayCopyImpl}};


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
#[derive(Drop, Serde, Copy)]
struct CombatantState {
    #[key]
    combat_id: u128,
    #[key]
    warrior_id: u128,
    stats: Stats,
    health: u8,
    stun_chance: u8
}

