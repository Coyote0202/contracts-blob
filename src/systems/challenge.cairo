use blob_arena::components::challenge::ChallengeScoreTrait;
use blob_arena::components::knockout::HealthsTrait;
use core::option::OptionTrait;
use starknet::{ContractAddress, get_caller_address};
use dojo::world::{IWorldDispatcherTrait};
use blob_arena::{
    components::{
        blobert::BlobertTrait,
        challenge::{
            ChallengeInvite, ChallengeResponse, Challenge, make_challenge, ChallengeTrait,
            ChallengeScore
        },
        combat::{Move, TwoMovesTrait}, world::{World}, utils::{Status, AB, Winner},
    },
    systems::{blobert::BlobertWorldTrait, knockout::{KnockoutGameTrait, KnockoutGame}}
};

#[generate_trait]
impl ChallengeImpl of ChallengeSystemTrait {
    fn get_challenge_invite(self: World, challenge_id: u128) -> ChallengeInvite {
        get!(self, challenge_id, ChallengeInvite)
    }

    fn get_challenge_response(self: World, challenge_id: u128) -> ChallengeResponse {
        get!(self, challenge_id, ChallengeResponse)
    }

    fn set_challenge_invite(self: Challenge) {
        set!(self.world, (self.invite(),))
    }

    fn set_challenge_response(self: Challenge) {
        set!(self.world, (self.response(),))
    }

    fn assert_caller_sender(self: Challenge) -> ContractAddress {
        let caller = get_caller_address();
        assert(self.sender == caller, 'Not the sender');
        caller
    }

    fn assert_caller_receiver(self: Challenge) -> ContractAddress {
        let caller = get_caller_address();
        assert(self.receiver == caller, 'Not the receiver');
        caller
    }

    fn get_challenge(self: World, challenge_id: u128) -> Challenge {
        make_challenge(
            self, self.get_challenge_invite(challenge_id), self.get_challenge_response(challenge_id)
        )
    }

    fn get_score(self: World, player: ContractAddress, blobert_id: u128) -> ChallengeScore {
        get!(self, (player, blobert_id), ChallengeScore)
    }

    fn get_game(self: Challenge) -> KnockoutGame {
        self.world.get_knockout_game(self.combat_id)
    }

    fn get_open_challenge(self: World, challenge_id: u128) -> Challenge {
        let challenge = self.get_challenge(challenge_id);
        assert(challenge.invite_open, 'Challenge already closed');
        assert(challenge.combat_id.is_zero(), 'Combat already started');
        challenge
    }

    fn get_running_challenge(self: World, challenge_id: u128) -> Challenge {
        let challenge = self.get_challenge(challenge_id);
        assert(challenge.combat_id.is_non_zero(), 'Combat not started');
        challenge
    }

    fn send_challenge_invite(
        self: World, receiver: ContractAddress, blobert_id: u128, phase_time: u64
    ) -> u128 {
        let challenge_id: u128 = self.uuid().into();
        let sender = get_caller_address();
        self.assert_blobert_owner(blobert_id, sender);
        let challenge = ChallengeInvite {
            challenge_id, sender, receiver, blobert_id, phase_time, open: true,
        };
        set!(self, (challenge,));
        challenge_id
    }

    fn rescind_challenge_invite(ref self: Challenge) {
        self.assert_caller_sender();
        self.invite_open = false;
        self.set_challenge_invite();
    }

    fn respond_challenge_invite(ref self: Challenge, blobert_id: u128) {
        let caller = self.assert_caller_receiver();
        assert(!self.response_open, 'Already responded');
        self.world.assert_blobert_owner(blobert_id, caller);
        self.receiver_blobert = blobert_id;
        self.response_open = true;
        self.set_challenge_response();
    }

    fn rescind_challenge_response(ref self: Challenge) {
        self.assert_caller_receiver();
        assert(self.response_open, 'Response already closed');
        self.response_open = false;
        self.set_challenge_response();
    }

    fn reject_challenge_invite(ref self: Challenge) {
        self.assert_caller_receiver();
        self.invite_open = false;
        self.set_challenge_invite();
    }

    fn accept_challenge_response(ref self: Challenge) -> u128 {
        self.assert_caller_sender();
        assert(self.response_open, 'Response already closed');
        self.make_game()
    }

    fn make_game(ref self: Challenge) -> u128 {
        self
            .combat_id = self
            .world
            .new_knockout(self.sender, self.receiver, self.sender_blobert, self.receiver_blobert,);
        self.set_challenge_response();
        self.combat_id
    }


    fn reject_challenge_response(ref self: Challenge) {
        self.assert_caller_sender();
        assert(self.response_open, 'Response already closed');
        self.response_open = false;
        self.set_challenge_response();
    }
    fn commit_challenge_move(self: Challenge, hash: felt252) {
        let game = self.get_game();
        game.commit_move(hash);
    }
    fn reveal_challenge_move(self: Challenge, move: Move, salt: felt252) {
        let game = self.get_game();
        game.reveal_move(move, salt);
        let status = game.get_status();
        match status {
            Status::Finished(winner) => { self.set_winner(winner.into()); },
            _ => {},
        }
    }

    fn set_winner(self: Challenge, winner: AB) {
        let (w_player, w_blobert) = self.get_player_and_blobert(winner);
        let (l_player, l_blobert) = self.get_player_and_blobert(!winner);
        let mut w_score = self.world.get_score(w_player, w_blobert);
        let mut l_score = self.world.get_score(l_player, l_blobert);
        w_score.win();
        l_score.lose();
        set!(self.world, (w_score, l_score));
    }

    fn forfeit_challenge(self: Challenge) {
        let game = self.get_game();
        let loser = game.get_caller_player();
        game.force_loss(loser);
        self.set_winner(!loser);
    }

    fn kick_inactive_challenge_player(self: Challenge) {
        let game = self.get_game();
        let caller = game.get_caller_player();
        game.assert_player_inactive(self.phase_time, !caller);
        game.force_loss(!caller);
        self.set_winner(caller);
    }
}
