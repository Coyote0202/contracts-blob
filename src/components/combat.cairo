use core::fmt::{Display, Formatter, Error};
use starknet::ContractAddress;
use blob_arena::{constants::U64_MASK_U256, components::utils::{AB, Status, Winner, DisplayImplT}};


#[derive(Copy, Drop, Print, Serde, SerdeLen, PartialEq, Introspect)]
enum Move {
    Beat,
    Counter,
    Rush,
}

#[derive(Copy, Drop, Print, Serde, SerdeLen, PartialEq, Introspect)]
enum MoveN {
    None,
    Beat,
    Counter,
    Rush,
}


#[generate_trait]
impl MoveNImpl of MoveNTrait {
    fn is_some(self: MoveN) -> bool {
        self != MoveN::None
    }
    fn move(self: MoveN) -> Move {
        match self {
            MoveN::Beat => Move::Beat,
            MoveN::Counter => Move::Counter,
            MoveN::Rush => Move::Rush,
            MoveN::None => { panic!("Move not set") },
        }
    }
}


impl MoveIntoByteArray of Into<Move, ByteArray> {
    fn into(self: Move) -> ByteArray {
        match self {
            Move::Beat => "Beat",
            Move::Counter => "Counter",
            Move::Rush => "Rush",
        }
    }
}

impl TIntoMove<T, +TryInto<T, u8>> of Into<T, Move> {
    fn into(self: T) -> Move {
        match self.try_into().unwrap() {
            0_u8 => Move::Beat,
            1_u8 => Move::Counter,
            2_u8 => Move::Rush,
            _ => panic!("Move id out of range"),
        }
    }
}

impl MoveIntoT<T, +Into<u8, T>> of Into<Move, T> {
    fn into(self: Move) -> T {
        let move_u8: u8 = match self {
            Move::Beat => 0_u8,
            Move::Counter => 1_u8,
            Move::Rush => 2_u8,
        };
        move_u8.into()
    }
}

#[derive(Copy, Drop, Serde)]
struct Reveal {
    move: Move,
    salt: felt252,
}

#[generate_trait]
impl RevealImpl of RevealTrait {
    fn create(move: Move, salt: felt252) -> Reveal {
        Reveal { move, salt }
    }
    fn get_hash(self: Reveal) -> felt252 {
        pedersen::pedersen(self.salt.into(), self.move.into())
    }
    fn check_hash(self: Reveal, hash: felt252) -> bool {
        self.get_hash() == hash
    }
}

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct TwoHashes {
    #[key]
    id: u128,
    a: felt252,
    b: felt252,
}

#[derive(Model, Copy, Drop, Print, Serde, SerdeLen)]
struct TwoMoves {
    #[key]
    id: u128,
    a: MoveN,
    b: MoveN,
}

#[generate_trait]
impl TwoMovesImpl of TwoMovesTrait {
    fn get_move(self: TwoMoves, player: AB) -> Move {
        let move: MoveN = match player {
            AB::A => self.a,
            AB::B => self.b,
        };
        assert(move.is_some(), 'Move not set');
        return move.move();
    }
    fn moves(self: TwoMoves) -> (Move, Move) {
        assert(self.a.is_some(), 'Move A not set');
        assert(self.b.is_some(), 'Move B not set');
        (self.a.move(), self.b.move())
    }
    fn set_move(ref self: TwoMoves, player: AB, move: Move) {
        let move_n = match move {
            Move::Beat => MoveN::Beat,
            Move::Counter => MoveN::Counter,
            Move::Rush => MoveN::Rush,
        };
        match player {
            AB::A => { self.a = move_n },
            AB::B => { self.b = move_n },
        };
    }
    fn check_set(self: TwoMoves, player: AB) -> bool {
        match player {
            AB::A => self.a,
            AB::B => self.b,
        }.is_some()
    }
    fn reset(ref self: TwoMoves) {
        self.a = MoveN::None;
        self.b = MoveN::None;
    }
    fn check_done(self: TwoMoves) -> bool {
        self.a.is_some() && self.b.is_some()
    }
}

#[generate_trait]
impl TwoHashesImpl of TwoHashesTrait {
    fn get_hash(self: TwoHashes, player: AB) -> felt252 {
        let hash = match player {
            AB::A => self.a,
            AB::B => self.b,
        };
        assert(hash.is_non_zero(), 'Hash not set');
        return hash;
    }
    fn check_set(self: TwoHashes, player: AB) -> bool {
        match player {
            AB::A => self.a,
            AB::B => self.b,
        }.is_non_zero()
    }
    fn check_done(self: TwoHashes) -> bool {
        self.a.is_non_zero() && self.b.is_non_zero()
    }
    fn reset(ref self: TwoHashes) {
        self.a = 0;
        self.b = 0;
    }
}


#[derive(Copy, Drop, Print, Serde)]
enum MatchResult {
    Winner: AB,
    Draw,
}

impl MatchResultIntoByteArray of Into<MatchResult, ByteArray> {
    fn into(self: MatchResult) -> ByteArray {
        match self {
            MatchResult::Winner(ab) => format!("winner {}", ab),
            MatchResult::Draw => "draw",
        }
    }
}

#[derive(Copy, Drop, Print, Serde)]
struct Outcome {
    result: MatchResult,
    move: Move
}

impl OutcomeIntoByteArray of Into<Outcome, ByteArray> {
    fn into(self: Outcome) -> ByteArray {
        let result: ByteArray = self.result.into();
        let move: ByteArray = self.move.into();
        format!("{} with move {}", result, move)
    }
}


impl DisplayImplOutcome = DisplayImplT<Outcome>;
impl DisplayImplMatchResult = DisplayImplT<MatchResult>;
impl DisplayImplMove = DisplayImplT<Move>;
impl DisplayImplAB = DisplayImplT<AB>;

