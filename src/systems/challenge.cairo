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
        combat::{Move, TwoMovesTrait}, world::{World}, utils::Status,
    },
    systems::{blobert::BlobertWorldTrait, knockout::{KnockoutGameTrait}}
};

#[generate_trait]
impl ChallengeImpl of ChallengeSystemTrait {
    fn get_challenge_invite(self: World, challenge_id: u128) -> ChallengeInvite {
        get!(self, challenge_id, ChallengeInvite)
    }

    fn get_challenge_response(self: World, challenge_id: u128) -> ChallengeResponse {
        get!(self, challenge_id, ChallengeResponse)
    }

    fn get_challenge(self: World, challenge_id: u128) -> Challenge {
        make_challenge(
            self.get_challenge_invite(challenge_id), self.get_challenge_response(challenge_id)
        )
    }
    fn get_score(self: World, player: ContractAddress, blobert_id: u128) -> ChallengeScore {
        get!(self, (player, blobert_id), ChallengeScore)
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

    fn send_challenge_invite(self: World, receiver: ContractAddress, blobert_id: u128) -> u128 {
        let challenge_id: u128 = self.uuid().into();
        let sender = get_caller_address();
        self.assert_blobert_owner(blobert_id, sender);
        let challenge = ChallengeInvite { challenge_id, sender, receiver, blobert_id, open: true, };
        set!(self, (challenge,));
        challenge_id
    }

    fn rescind_challenge_invite(self: World, challenge_id: u128) {
        let caller = get_caller_address();
        let mut challenge = self.get_open_challenge(challenge_id);
        assert(challenge.sender == caller, 'Not the sender');
        challenge.invite_open = false;
        let challenge_invite = challenge.invite();
        set!(self, (challenge_invite,));
    }

    fn respond_challenge_invite(self: World, challenge_id: u128, blobert_id: u128) {
        let caller = get_caller_address();
        let mut challenge = self.get_open_challenge(challenge_id);
        assert(challenge.receiver == caller, 'Not the receiver');
        assert(!challenge.response_open, 'Already responded');
        self.assert_blobert_owner(blobert_id, caller);
        challenge.receiver_blobert = blobert_id;
        challenge.response_open = true;
        set!(self, (challenge.response(),));
    }

    fn rescind_challenge_response(self: World, challenge_id: u128) {
        let caller = get_caller_address();
        let mut challenge = self.get_open_challenge(challenge_id);
        assert(challenge.receiver == caller, 'Not the receiver');
        assert(challenge.response_open, 'Response already closed');
        challenge.response_open = false;
        set!(self, (challenge.response(),));
    }

    fn reject_challenge_invite(self: World, challenge_id: u128) {
        let caller = get_caller_address();
        let mut challenge = self.get_open_challenge(challenge_id);
        assert(challenge.receiver == caller, 'Not the receiver');
        challenge.invite_open = false;
        set!(self, (challenge.invite(),));
    }

    fn accept_challenge_response(self: World, challenge_id: u128) -> u128 {
        let caller = get_caller_address();
        let mut challenge = self.get_open_challenge(challenge_id);
        assert(challenge.sender == caller, 'Not the sender');
        assert(challenge.response_open, 'Response already closed');
        challenge
            .combat_id = self
            .new_knockout(
                challenge.sender,
                challenge.receiver,
                challenge.sender_blobert,
                challenge.receiver_blobert
            );
        set!(self, (challenge.response(),));
        challenge.combat_id
    }

    fn reject_challenge_response(self: World, challenge_id: u128) {
        let caller = get_caller_address();
        let mut challenge = self.get_open_challenge(challenge_id);
        assert(challenge.sender == caller, 'Not the sender');
        assert(challenge.response_open, 'Response already closed');
        challenge.response_open = false;
        set!(self, (challenge.response(),));
    }
    fn commit_challenge_move(self: World, challenge_id: u128, hash: felt252) {
        let mut challenge = self.get_running_challenge(challenge_id);
        let combat_id = challenge.combat_id;
        let game = self.get_knockout_game(combat_id);
        game.commit_move(hash)
    }
    fn reveal_challenge_move(self: World, challenge_id: u128, move: Move, salt: felt252) {
        let mut challenge = self.get_running_challenge(challenge_id);
        let combat_id = challenge.combat_id;
        let game = self.get_knockout_game(combat_id);
        game.reveal_move(move, salt);
        let status = game.get_status();
        match status {
            Status::Finished(winner) => {
                let (w_player, w_blobert) = challenge.get_player_and_blobert(winner.into());
                let (l_player, l_blobert) = challenge.get_player_and_blobert(!(winner.into()));
                let mut w_score = self.get_score(w_player, w_blobert);
                let mut l_score = self.get_score(l_player, l_blobert);
                w_score.win();
                l_score.lose();
                set!(self, (w_score, l_score));
            },
            _ => {},
        }
    }
}
