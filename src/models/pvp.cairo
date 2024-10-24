use blob_arena::components::{combat::{Phase}, utils::{AB, ABT}};
use starknet::{ContractAddress};

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum PvPWinner {
    None,
    A,
    B
}

impl PvPWinnerIntoAB of Into<PvPWinner, AB> {
    fn into(self: PvPWinner) -> AB {
        match self {
            PvPWinner::A => AB::A,
            PvPWinner::B => AB::B,
            PvPWinner::None => panic!("Cannot convert None to AB"),
        }
    }
}

impl ABIntoPvPWinner of Into<AB, PvPWinner> {
    fn into(self: AB) -> PvPWinner {
        match self {
            AB::A => PvPWinner::A,
            AB::B => PvPWinner::B,
        }
    }
}

// impl PvPPhaseDropImpl of Drop<PvPPhase>;

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct PvPCombatants {
    #[key]
    id: felt252,
    combatants: (felt252, felt252),
}


#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct PvPChallengeScore {
    #[key]
    player: ContractAddress,
    #[key]
    collection_address: ContractAddress,
    #[key]
    token_high: u128,
    #[key]
    token_low: u128,
    wins: u64,
    losses: u64,
    max_consecutive_wins: u64,
    current_consecutive_wins: u64,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct PvPChallengeInvite {
    #[key]
    id: felt252,
    sender: ContractAddress,
    receiver: ContractAddress,
    collection_address: ContractAddress,
    combatant: felt252,
    phase_time: u64,
    open: bool,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct PvPChallengeResponse {
    #[key]
    id: felt252,
    combatant: felt252,
    open: bool,
}
