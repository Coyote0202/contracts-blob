use starknet::{ContractAddress};
use blob_arena::{components::{utils::{Winner, AB}, world::World}};

#[dojo::model]
#[derive(Copy, Drop, Print, Serde)]
struct ChallengeScore {
    #[key]
    player: ContractAddress,
    #[key]
    blobert_id: u128,
    wins: u64,
    losses: u64,
    max_consecutive_wins: u64,
    current_consecutive_wins: u64,
}

#[dojo::model]
#[derive(Copy, Drop, Print, Serde)]
struct ChallengeInvite {
    #[key]
    challenge_id: u128,
    sender: ContractAddress,
    receiver: ContractAddress,
    blobert_id: u128,
    phase_time: u64,
    open: bool,
    arcade: bool
}

#[dojo::model]
#[derive(Copy, Drop, Print, Serde)]
struct ChallengeResponse {
    #[key]
    challenge_id: u128,
    blobert_id: u128,
    open: bool,
    combat_id: u128,
}

#[derive(Copy, Drop, Print, Serde)]
struct Challenge {
    world: World,
    challenge_id: u128,
    sender: ContractAddress,
    receiver: ContractAddress,
    sender_blobert: u128,
    receiver_blobert: u128,
    phase_time: u64,
    invite_open: bool,
    response_open: bool,
    combat_id: u128,
    arcade: bool,
}


fn make_challenge(world: World, invite: ChallengeInvite, response: ChallengeResponse) -> Challenge {
    Challenge {
        world,
        challenge_id: invite.challenge_id,
        sender: invite.sender,
        receiver: invite.receiver,
        sender_blobert: invite.blobert_id,
        receiver_blobert: response.blobert_id,
        phase_time: invite.phase_time,
        invite_open: invite.open,
        response_open: response.open,
        combat_id: response.combat_id,
        arcade: invite.arcade,
    }
}

#[generate_trait]
impl ChallengeImpl of ChallengeTrait {
    fn invite(self: Challenge) -> ChallengeInvite {
        ChallengeInvite {
            challenge_id: self.challenge_id,
            sender: self.sender,
            receiver: self.receiver,
            blobert_id: self.sender_blobert,
            phase_time: self.phase_time,
            open: self.invite_open,
            arcade: self.arcade,
        }
    }
    fn response(self: Challenge) -> ChallengeResponse {
        ChallengeResponse {
            challenge_id: self.challenge_id,
            blobert_id: self.receiver_blobert,
            open: self.response_open,
            combat_id: self.combat_id,
        }
    }
    fn get_player_and_blobert(self: Challenge, ab: AB) -> (ContractAddress, u128) {
        match ab {
            AB::A => (self.sender, self.sender_blobert),
            AB::B => (self.receiver, self.receiver_blobert),
        }
    }
}

#[generate_trait]
impl ChallengeScoreImpl of ChallengeScoreTrait {
    fn win(ref self: ChallengeScore) {
        self.current_consecutive_wins += 1;
        self.wins += 1;
        if self.current_consecutive_wins > self.max_consecutive_wins {
            self.max_consecutive_wins = self.current_consecutive_wins;
        }
    }
    fn lose(ref self: ChallengeScore) {
        self.current_consecutive_wins = 0;
        self.losses += 1;
    }
}

