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
    id: u128,
    combatants: (u128, u128),
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
    id: u128,
    sender: ContractAddress,
    receiver: ContractAddress,
    collection_address: ContractAddress,
    combatant: u128,
    phase_time: u64,
    open: bool,
}

#[dojo::model]
#[derive(Copy, Drop, Serde)]
struct PvPChallengeResponse {
    #[key]
    id: u128,
    combatant: u128,
    open: bool,
}
