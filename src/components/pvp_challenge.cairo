use starknet::{ContractAddress, get_caller_address, get_block_number};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    components::{
        combat::{Phase, CombatStateTrait}, combatant::{CombatantInfo, CombatantTrait},
        utils::{Winner, AB, ABT, ABTTrait}, pvp_combat::PvPCombatTrait
    },
    models::{PvPChallengeInvite, PvPChallengeResponse, PvPChallengeScoreModel, PvPCombatantsModel}
};

#[derive(Copy, Drop, Serde)]
struct PvPChallenge {
    id: u128,
    sender: ContractAddress,
    receiver: ContractAddress,
    sender_combatant: u128,
    receiver_combatant: u128,
    phase_time: u64,
    invite_open: bool,
    response_open: bool,
    collection_address: ContractAddress,
}


fn make_challenge(
    world: @IWorldDispatcher, invite: PvPChallengeInvite, response: PvPChallengeResponse
) -> PvPChallenge {
    PvPChallenge {
        id: invite.id,
        sender: invite.sender,
        receiver: invite.receiver,
        sender_combatant: invite.combatant,
        receiver_combatant: response.combatant,
        phase_time: invite.phase_time,
        invite_open: invite.open,
        response_open: response.open,
        collection_address: invite.collection_address,
    }
}


#[generate_trait]
impl PvPChallengeImpl of PvPChallengeTrait {
    fn get_challenge_invite(self: @IWorldDispatcher, challenge_id: u128) -> PvPChallengeInvite {
        get!((*self), challenge_id, PvPChallengeInvite)
    }

    fn get_challenge_response(self: @IWorldDispatcher, challenge_id: u128) -> PvPChallengeResponse {
        get!((*self), challenge_id, PvPChallengeResponse)
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
        collection_address: ContractAddress,
        combatant_id: u128,
        phase_time: u64,
    ) {
        set!(
            self,
            PvPChallengeInvite {
                id: challenge_id,
                sender,
                receiver,
                collection_address,
                combatant: combatant_id,
                phase_time,
                open: true,
            }
        );
    }

    fn assert_caller_sender(self: @PvPChallenge) -> ContractAddress {
        let caller = get_caller_address();
        assert(*self.sender == caller, 'Not the sender');
        caller
    }

    fn assert_caller_receiver(self: @PvPChallenge) -> ContractAddress {
        let caller = get_caller_address();
        assert(*self.receiver == caller, 'Not the receiver');
        caller
    }

    fn get_challenge(self: @IWorldDispatcher, challenge_id: u128) -> PvPChallenge {
        make_challenge(
            self, self.get_challenge_invite(challenge_id), self.get_challenge_response(challenge_id)
        )
    }

    fn get_open_challenge(self: @IWorldDispatcher, challenge_id: u128) -> PvPChallenge {
        let challenge = self.get_challenge(challenge_id);
        assert(challenge.invite_open, 'Challenge already closed');

        assert(self.get_combat_phase(challenge_id) == Phase::Setup, 'Combat already started');
        challenge
    }

    fn invite(self: PvPChallenge) -> PvPChallengeInvite {
        PvPChallengeInvite {
            id: self.id,
            sender: self.sender,
            receiver: self.receiver,
            combatant: self.sender_combatant,
            phase_time: self.phase_time,
            open: self.invite_open,
            collection_address: self.collection_address,
        }
    }
    fn response(self: PvPChallenge) -> PvPChallengeResponse {
        PvPChallengeResponse {
            id: self.id, combatant: self.receiver_combatant, open: self.response_open,
        }
    }
    fn create_game(self: IWorldDispatcher, challenge: PvPChallenge) {
        self
            .set_pvp_combatants(
                challenge.id, (challenge.sender_combatant, challenge.receiver_combatant)
            );
        self.new_combat_state(challenge.id);
    }
}

#[generate_trait]
impl PvPChallengeScoreImpl of PvPChallengeScoreTrait {
    fn get_score(
        self: @IWorldDispatcher,
        player: ContractAddress,
        collection_address: ContractAddress,
        token_id: u256
    ) -> PvPChallengeScoreModel {
        get!(
            (*self),
            (player, collection_address, token_id.high, token_id.low),
            PvPChallengeScoreModel
        )
    }
    fn win(ref self: PvPChallengeScoreModel) {
        self.current_consecutive_wins += 1;
        self.wins += 1;
        if self.current_consecutive_wins > self.max_consecutive_wins {
            self.max_consecutive_wins = self.current_consecutive_wins;
        }
    }
    fn lose(ref self: PvPChallengeScoreModel) {
        self.current_consecutive_wins = 0;
        self.losses += 1;
    }
    fn update_scores(self: IWorldDispatcher, winner: CombatantInfo, loser: CombatantInfo) {
        let mut winner_score = self
            .get_score(winner.player, winner.collection_address, winner.token_id);
        let mut loser_score = self
            .get_score(loser.player, loser.collection_address, loser.token_id);
        winner_score.win();
        loser_score.lose();
        set!(self, (winner_score, loser_score));
    }
}

