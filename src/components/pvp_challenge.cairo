use starknet::{ContractAddress};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    components::{utils::{Winner, AB}},
    models::{PvPChallengeInvite, PvPChallengeResponse, PvPChallengeScore,}
};

#[derive(Copy, Drop, Print, Serde)]
struct PvPChallenge {
    challenge_id: u128,
    sender: ContractAddress,
    receiver: ContractAddress,
    sender_warrior: u128,
    receiver_warrior: u128,
    phase_time: u64,
    invite_open: bool,
    response_open: bool,
    combat_id: u128,
    collection: ContractAddress,
}


fn make_challenge(
    world: IWorldDispatcher, invite: PvPChallengeInvite, response: PvPChallengeResponse
) -> PvPChallenge {
    PvPChallenge {
        challenge_id: invite.challenge_id,
        sender: invite.sender,
        receiver: invite.receiver,
        sender_warrior: invite.warrior_id,
        receiver_warrior: response.warrior_id,
        phase_time: invite.phase_time,
        invite_open: invite.open,
        response_open: response.open,
        combat_id: response.combat_id,
        arcade: invite.arcade,
    }
}

#[generate_trait]
impl PvPChallengeImpl of PvPChallengeTrait {
    fn invite(self: PvPChallenge) -> PvPChallengeInvite {
        PvPChallengeInvite {
            challenge_id: self.challenge_id,
            sender: self.sender,
            receiver: self.receiver,
            warrior_id: self.sender_warrior,
            phase_time: self.phase_time,
            open: self.invite_open,
            arcade: self.arcade,
        }
    }
    fn response(self: PvPChallenge) -> PvPChallengeResponse {
        PvPChallengeResponse {
            challenge_id: self.challenge_id,
            warrior_id: self.receiver_warrior,
            open: self.response_open,
            combat_id: self.combat_id,
        }
    }
    fn get_player_and_warrior(self: PvPChallenge, ab: AB) -> (ContractAddress, u128) {
        match ab {
            AB::A => (self.sender, self.sender_warrior),
            AB::B => (self.receiver, self.receiver_warrior),
        }
    }
}

#[generate_trait]
impl PvPChallengeScoreImpl of PvPChallengeScoreTrait {
    fn win(ref self: PvPChallengeScore) {
        self.current_consecutive_wins += 1;
        self.wins += 1;
        if self.current_consecutive_wins > self.max_consecutive_wins {
            self.max_consecutive_wins = self.current_consecutive_wins;
        }
    }
    fn lose(ref self: PvPChallengeScore) {
        self.current_consecutive_wins = 0;
        self.losses += 1;
    }
}

