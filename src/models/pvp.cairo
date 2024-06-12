use blob_arena::components::combat::Phase;
use starknet::{ContractAddress};

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct PvPCombat {
    #[key]
    id: u128,
    combatants: (u128, u128),
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct PvPCombatState {
    #[key]
    id: u128,
    players_state: (bool, bool),
    phase: Phase,
    round: u32,
}

#[dojo::model]
#[derive(Drop, Serde)]
struct PvPPlannedAttack {
    #[key]
    combat_id: u128,
    #[key]
    warrior_id: u128,
    attack: u128,
}


#[dojo::model]
#[derive(Copy, Drop, Print, Serde)]
struct PvPChallengeScore {
    #[key]
    player: ContractAddress,
    #[key]
    warrior_id: u128,
    wins: u64,
    losses: u64,
    max_consecutive_wins: u64,
    current_consecutive_wins: u64,
}

#[dojo::model]
#[derive(Copy, Drop, Print, Serde)]
struct PvPChallengeInvite {
    #[key]
    challenge_id: u128,
    sender: ContractAddress,
    receiver: ContractAddress,
    warrior_id: u128,
    phase_time: u64,
    open: bool,
    arcade: bool
}

#[dojo::model]
#[derive(Copy, Drop, Print, Serde)]
struct PvPChallengeResponse {
    #[key]
    challenge_id: u128,
    warrior_id: u128,
    open: bool,
    combat_id: u128,
}
