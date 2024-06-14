use starknet::{ContractAddress, get_caller_address, get_block_number};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    components::{combat::Phase, utils::{Winner, AB}},
    models::{
        PvPChallengeInvite, PvPChallengeResponse, PvPChallengeScore, PvPCombatModel,
        PvPCombatStateModel
    }
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
    collection_address: ContractAddress,
}


impl PvPChallengeIntoPvPCombatImpl of Into<PvPChallenge, (PvPCombatModel, PvPCombatStateModel)> {
    fn into(self: PvPChallenge) -> (PvPCombatModel, PvPCombatStateModel) {
        (
            PvPCombatModel {
                id: self.challenge_id, combatants: (self.sender_warrior, self.receiver_warrior),
            },
            PvPCombatStateModel {
                id: self.challenge_id,
                players_state: (false, false),
                phase: Phase::Commit,
                round: 0,
                block_number: get_block_number(),
            }
        )
    }
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
        collection_address: invite.collection_address,
    }
}


#[generate_trait]
impl PvPChallengeImpl of PvPChallengeTrait {
    fn get_challenge_invite(self: IWorldDispatcher, challenge_id: u128) -> PvPChallengeInvite {
        get!(self, challenge_id, PvPChallengeInvite)
    }

    fn get_challenge_response(self: IWorldDispatcher, challenge_id: u128) -> PvPChallengeResponse {
        get!(self, challenge_id, PvPChallengeResponse)
    }

    fn set_challenge_invite(self: IWorldDispatcher, challenge: PvPChallenge) {
        set!(self, (challenge.invite(),))
    }

    fn set_challenge_response(self: IWorldDispatcher, challenge: PvPChallenge) {
        set!(self, (challenge.response(),))
    }

    fn send_challenge_invite(
        self: IWorldDispatcher,
        challenge_id: u128,
        sender: ContractAddress,
        receiver: ContractAddress,
        warrior_id: u128,
        phase_time: u64,
        collection_address: ContractAddress
    ) {
        set!(
            self,
            PvPChallengeInvite {
                challenge_id,
                sender,
                receiver,
                warrior_id,
                phase_time,
                open: true,
                collection_address
            }
        );
    }

    fn assert_caller_sender(self: PvPChallenge) -> ContractAddress {
        let caller = get_caller_address();
        assert(self.sender == caller, 'Not the sender');
        caller
    }

    fn to_combat(self: PvPChallenge) -> (PvPCombatModel, PvPCombatStateModel) {
        self.into()
    }

    fn assert_caller_receiver(self: PvPChallenge) -> ContractAddress {
        let caller = get_caller_address();
        assert(self.receiver == caller, 'Not the receiver');
        caller
    }

    fn get_challenge(self: IWorldDispatcher, challenge_id: u128) -> PvPChallenge {
        make_challenge(
            self, self.get_challenge_invite(challenge_id), self.get_challenge_response(challenge_id)
        )
    }

    fn get_open_challenge(self: IWorldDispatcher, challenge_id: u128) -> PvPChallenge {
        let challenge = self.get_challenge(challenge_id);
        assert(challenge.invite_open, 'Challenge already closed');
        assert(challenge.combat_id.is_zero(), 'Combat already started');
        challenge
    }

    fn get_running_challenge(self: IWorldDispatcher, challenge_id: u128) -> PvPChallenge {
        let challenge = self.get_challenge(challenge_id);
        assert(challenge.combat_id.is_non_zero(), 'Combat not started');
        challenge
    }

    fn invite(self: PvPChallenge) -> PvPChallengeInvite {
        PvPChallengeInvite {
            challenge_id: self.challenge_id,
            sender: self.sender,
            receiver: self.receiver,
            warrior_id: self.sender_warrior,
            phase_time: self.phase_time,
            open: self.invite_open,
            collection_address: self.collection_address,
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
    fn create_game(self: IWorldDispatcher, challenge: PvPChallenge) {
        let (challenge, state) = challenge.to_combat();
        set!(self, (challenge, state));
    }
}

#[generate_trait]
impl PvPChallengeScoreImpl of PvPChallengeScoreTrait {
    fn get_score(
        self: IWorldDispatcher, player: ContractAddress, wairror_id: u128
    ) -> PvPChallengeScore {
        get!(self, (player, wairror_id), PvPChallengeScore)
    }
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

