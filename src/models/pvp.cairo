use blob_arena::components::{combat::{Phase, AttackResult}, utils::{AB, ABT}};
use starknet::{ContractAddress};
use dojo::database::introspect::Introspect;

#[derive(Copy, Drop, Print, Serde, SerdeLen, PartialEq, Introspect)]
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

type PvPPhase = Phase<PvPWinner>;
// impl PvPPhaseDropImpl of Drop<PvPPhase>;

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct PvPCombat {
    #[key]
    id: u128,
    combatants: (u128, u128),
}

#[dojo::model]
#[derive(Drop, Serde, Copy, Introspect)]
struct PvPCombatState {
    #[key]
    id: u128,
    players_state: (bool, bool),
    round: u32,
    phase: PvPPhase,
    block_number: u64,
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
    collection_address: ContractAddress
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

#[dojo::model]
#[derive(Copy, Drop, Print, Serde, Introspect)]
struct PvPRoundEvent {
    #[key]
    combat_id: u128,
    first: AB,
    attack_results: ABT<AttackResult>
}
