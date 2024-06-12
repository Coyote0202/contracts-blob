use core::{fmt::{Display, Formatter, Error}, poseidon::{poseidon_hash_span}};
use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    components::{combatant::{Combatant}, utils::{ABT, Status, Winner, DisplayImplT}},
    models::SaltsModel
};

struct Team {
    id: u128,
    players: Array<u128>,
}

struct PlayerCombat {
    id: u128,
    phase: Phase,
}

struct Round {
    combat_id: u128,
}

struct TeamCombat {
    id: u128,
    teams: Array<Team>,
    phase: Phase,
}

#[dojo::model]
#[derive(Copy, Drop, Print, Serde)]
struct CurrentPhase {
    #[key]
    id: u128,
    block_number: u64,
    phase: Phase,
}

#[derive(Copy, Drop, Print, Serde, SerdeLen, PartialEq, Introspect)]
enum Phase {
    Setup,
    Commit,
    Reveal,
    Ended,
}

type Salts = Array<felt252>;

#[generate_trait]
impl SaltsImpl of SaltsTrait {
    fn get_salts_model(self: @IWorldDispatcher, id: u128) -> SaltsModel {
        get!((*self), id, SaltsModel)
    }

    fn append_salt(self: @IWorldDispatcher, id: u128, salt: felt252) {
        let mut model = self.get_salts_model(id);
        model.salts.append(salt);
        set!((*self), (model,));
    }

    fn reset_salts(self: @IWorldDispatcher, id: u128) {
        set!((*self), (SaltsModel { id, salts: ArrayTrait::new(), },));
    }

    fn get_salts_hash(self: @IWorldDispatcher, id: u128) -> felt252 {
        let model = self.get_salts_model(id);
        poseidon_hash_span(model.salts.span())
    }

    fn get_salts_with_salt_hash(self: @IWorldDispatcher, id: u128, salt: felt252) -> felt252 {
        let model = self.get_salts_model(id);
        let mut salts = model.salts;
        salts.append(salt);
        poseidon_hash_span(salts.span())
    }

    fn consume_with_salt(self: @IWorldDispatcher, id: u128, salt: felt252) -> felt252 {
        let hash = self.get_salts_with_salt_hash(id, salt);
        self.reset_salts(id);
        hash
    }
}


impl 
// #[derive(Copy, Drop, Serde)]
// struct Reveal {
//     move: Move,
//     salt: felt252,
// }

// #[generate_trait]
// impl RevealImpl of RevealTrait {
//     fn create(move: Move, salt: felt252) -> Reveal {
//         Reveal { move, salt }
//     }
//     fn get_hash(self: Reveal) -> felt252 {
//         pedersen::pedersen(self.salt.into(), self.move.into())
//     }
//     fn check_hash(self: Reveal, hash: felt252) -> bool {
//         self.get_hash() == hash
//     }
// }
// #[dojo::model]
// #[derive(Copy, Drop, Print, Serde, SerdeLen)]
// struct TwoHashes {
//     #[key]
//     id: u128,
//     a: felt252,
//     b: felt252,
// }

// #[dojo::model]
// #[derive(Copy, Drop, Print, Serde, SerdeLen)]
// struct TwoMoves {
//     #[key]
//     id: u128,
//     a: MoveN,
//     b: MoveN,
// }

// #[generate_trait]
// impl TwoMovesImpl of TwoMovesTrait {
//     fn get_move(self: TwoMoves, player: AB) -> Move {
//         let move: MoveN = match player {
//             AB::A => self.a,
//             AB::B => self.b,
//         };
//         assert(move.is_some(), 'Move not set');
//         return move.move();
//     }
//     fn moves(self: TwoMoves) -> (Move, Move) {
//         assert(self.a.is_some(), 'Move A not set');
//         assert(self.b.is_some(), 'Move B not set');
//         (self.a.move(), self.b.move())
//     }
//     fn set_move(ref self: TwoMoves, player: AB, move: Move) {
//         let move_n = match move {
//             Move::Beat => MoveN::Beat,
//             Move::Counter => MoveN::Counter,
//             Move::Rush => MoveN::Rush,
//         };
//         match player {
//             AB::A => { self.a = move_n },
//             AB::B => { self.b = move_n },
//         };
//     }
//     fn check_set(self: TwoMoves, player: AB) -> bool {
//         match player {
//             AB::A => self.a,
//             AB::B => self.b,
//         }.is_some()
//     }
//     fn reset(ref self: TwoMoves) {
//         self.a = MoveN::None;
//         self.b = MoveN::None;
//     }
//     fn check_done(self: TwoMoves) -> bool {
//         self.a.is_some() && self.b.is_some()
//     }
// }

// #[generate_trait]
// impl TwoHashesImpl of TwoHashesTrait {
//     fn get_hash(self: TwoHashes, player: AB) -> felt252 {
//         let hash = match player {
//             AB::A => self.a,
//             AB::B => self.b,
//         };
//         assert(hash.is_non_zero(), 'Hash not set');
//         return hash;
//     }
//     fn check_set(self: TwoHashes, player: AB) -> bool {
//         match player {
//             AB::A => self.a,
//             AB::B => self.b,
//         }.is_non_zero()
//     }
//     fn check_done(self: TwoHashes) -> bool {
//         self.a.is_non_zero() && self.b.is_non_zero()
//     }
//     fn reset(ref self: TwoHashes) {
//         self.a = 0;
//         self.b = 0;
//     }
// }

// #[derive(Copy, Drop, Print, Serde)]
// enum MatchResult {
//     Winner: AB,
//     Draw,
// }

// impl MatchResultIntoByteArray of Into<MatchResult, ByteArray> {
//     fn into(self: MatchResult) -> ByteArray {
//         match self {
//             MatchResult::Winner(ab) => format!("winner {}", ab),
//             MatchResult::Draw => "draw",
//         }
//     }
// }

// #[derive(Copy, Drop, Print, Serde)]
// struct Outcome {
//     result: MatchResult,
//     move: Move
// }

// impl OutcomeIntoByteArray of Into<Outcome, ByteArray> {
//     fn into(self: Outcome) -> ByteArray {
//         let result: ByteArray = self.result.into();
//         let move: ByteArray = self.move.into();
//         format!("{} with move {}", result, move)
//     }
// }

// impl DisplayImplOutcome = DisplayImplT<Outcome>;
// impl DisplayImplMatchResult = DisplayImplT<MatchResult>;
// impl DisplayImplMove = DisplayImplT<Move>;
// impl DisplayImplAB = DisplayImplT<AB>;


