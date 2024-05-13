use blob_arena::components::combat::TwoHashesTrait;
use blob_arena::components::combat::TwoMovesTrait;
use blob_arena::{
    components::{
        blobert::{Blobert, BlobertTrait},
        combat::{Move, TwoHashes, RevealTrait, TwoMoves, CurrentPhase, Phase}, world::World,
        knockout::{Knockout, Healths, HealthsTrait, RoundTrait}, utils::{AB, Status, Winner},
        stake::Stake,
    },
    systems::{blobert::{BlobertWorldTrait}, combat::{Outcome, calculate_damage, get_outcome}},
    utils::{uuid},
};
use starknet::{ContractAddress, get_caller_address, get_block_number};
use dojo::world::{IWorldDispatcherTrait};

#[derive(Copy, Drop, Serde)]
struct KnockoutGame {
    world: World,
    combat_id: u128,
    player_a: ContractAddress,
    player_b: ContractAddress,
    blobert_a: u128,
    blobert_b: u128,
}

#[generate_trait]
impl KnockoutGameImpl of KnockoutGameTrait {
    fn new_knockout(
        self: World,
        player_a: ContractAddress,
        player_b: ContractAddress,
        blobert_a: u128,
        blobert_b: u128
    ) -> u128 {
        let combat_id = uuid(self);
        (self.get_blobert(blobert_a), self.get_blobert(blobert_b));
        let knockout = Knockout { combat_id, player_a, player_b, blobert_a, blobert_b };
        let healths = Healths { combat_id, a: 100, b: 100 };
        let phase = CurrentPhase {
            id: combat_id, phase: Phase::Commit, block_number: get_block_number()
        };
        set!(self, (knockout, healths, phase));
        combat_id
    }
    fn get_knockout_game(self: World, combat_id: u128) -> KnockoutGame {
        let model: Knockout = get!(self, combat_id, Knockout);
        KnockoutGame {
            world: self,
            combat_id,
            player_a: model.player_a,
            player_b: model.player_b,
            blobert_a: model.blobert_a,
            blobert_b: model.blobert_b,
        }
    }
    fn get_blobert(self: KnockoutGame, player: AB) -> Blobert {
        match player {
            AB::A => self.world.get_blobert(self.blobert_a),
            AB::B => self.world.get_blobert(self.blobert_b),
        }
    }
    fn get_player_id(self: KnockoutGame, player: AB) -> ContractAddress {
        match player {
            AB::A => self.player_a,
            AB::B => self.player_b,
        }
    }
    fn get_bloberts(self: KnockoutGame) -> (Blobert, Blobert) {
        (self.world.get_blobert(self.blobert_a), self.world.get_blobert(self.blobert_b))
    }
    fn get_healths(self: KnockoutGame) -> Healths {
        get!(self.world, self.combat_id, Healths)
    }
    // fn get_round(self: KnockoutGame) -> Round {
    //     get!(self.world, self.combat_id, Round)
    // }
    fn get_commitments(self: KnockoutGame) -> TwoHashes {
        get!(self.world, self.combat_id, TwoHashes)
    }
    fn get_moves(self: KnockoutGame) -> TwoMoves {
        get!(self.world, self.combat_id, TwoMoves)
    }

    fn get_stake(self: KnockoutGame) -> Stake {
        get!(self.world, self.combat_id, Stake)
    }

    fn get_phase(self: KnockoutGame) -> CurrentPhase {
        get!(self.world, self.combat_id, CurrentPhase)
    }

    fn set_phase(self: KnockoutGame, phase: Phase) {
        let phase = CurrentPhase { id: self.combat_id, phase, block_number: get_block_number() };
        set!(self.world, (phase,))
    }

    fn get_caller_player(self: KnockoutGame) -> AB {
        let caller = get_caller_address();
        if caller == self.player_a {
            return AB::A;
        }
        if caller == self.player_b {
            return AB::B;
        };
        panic!("Player not part of combat")
    }
    fn commit_move(self: KnockoutGame, hash: felt252) {
        self.assert_running();
        let player = self.get_caller_player();
        let mut commitments = self.get_commitments();
        match player {
            AB::A => {
                assert(commitments.a == 0, 'Already committed');
                commitments.a = hash;
            },
            AB::B => {
                assert(commitments.b == 0, 'Already committed');
                commitments.b = hash;
            },
        };
        if commitments.check_done() {
            self.set_phase(Phase::Reveal);
        }
        set!(self.world, (commitments,));
    }

    fn reveal_move(self: KnockoutGame, move: Move, salt: felt252) {
        let player = self.get_caller_player();
        let reveal = RevealTrait::create(move, salt);
        let mut commitments = self.get_commitments();
        let mut moves = self.get_moves();

        assert(!moves.check_set(player), 'Already revealed');
        assert(reveal.check_hash(commitments.get_hash(player)), 'Hash dose not match');
        moves.set_move(player, move);
        if moves.check_done() {
            self.verify_round(ref commitments, ref moves);
            self.set_phase(Phase::Commit);
        } else {
            set!(self.world, (moves,));
        };
    }

    fn verify_round(self: KnockoutGame, ref commitments: TwoHashes, ref moves: TwoMoves) {
        let (blobert_a, blobert_b) = self.get_bloberts();
        let mut healths = self.get_healths();
        let (move_a, move_b) = moves.moves();

        let outcome = get_outcome(move_a, move_b);
        let (damage_a, damage_b) = calculate_damage(blobert_a.stats, blobert_b.stats, outcome);
        let round = RoundTrait::create(self.combat_id, healths, moves, damage_a, damage_b);
        moves.reset();
        commitments.reset();
        healths.apply_damage(damage_a, damage_b);
        if healths.a == 0 && healths.b == 0 {
            healths.a = 1;
            healths.b = 1;
        };
        set!(self.world, (healths, commitments, moves, round));
    }

    fn end_game(self: KnockoutGame) {
        let stake = self.get_stake();
        let status = self.get_status();
        let outcome = match status {
            Status::Finished(outcome) => outcome,
            Status::Running => panic!("Game not finished"),
        };
        if outcome != Winner::Draw {
            let winner: AB = outcome.into();
            if stake.blobert {
                let mut blobert = self.get_blobert(!winner);
                let player_id = self.get_player_id(winner.into());
                self.world.transfer_blobert(ref blobert, player_id);
            }
            if stake.amount > 0 {}
        }
    }

    fn get_status(self: KnockoutGame) -> Status {
        let healths = self.get_healths();
        healths.status()
    }
    fn assert_running(self: KnockoutGame) {
        let status = self.get_status();
        assert(status == Status::Running, 'Game not running');
    }
    fn force_loss(self: KnockoutGame, player: AB) {
        let mut healths = self.get_healths();
        match player {
            AB::A => healths.a = 0,
            AB::B => healths.b = 0,
        };
        let mut moves = self.get_moves();
        let mut commitments = self.get_commitments();
        moves.reset();
        commitments.reset();
        set!(self.world, (healths, moves, commitments));
    }

    fn assert_player_inactive(self: KnockoutGame, block_limit: u64, player: AB) {
        let phase = self.get_phase();
        assert(get_block_number() > phase.block_number + block_limit, 'Time limit not reached');
        let set = match phase.phase {
            Phase::Commit => {
                let commitments = self.get_commitments();
                commitments.check_set(player)
            },
            Phase::Reveal => {
                let moves = self.get_moves();
                moves.check_set(player)
            },
        };
        assert(set, 'Player has already acted');
    }
}
