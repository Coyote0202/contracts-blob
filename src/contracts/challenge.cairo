use starknet::ContractAddress;
use blob_arena::components::combat::Move;
#[starknet::interface]
trait IChallengeActions<TContractState> {
    fn send_invite(self: @TContractState, receiver: ContractAddress, blobert_id: u128) -> u128;
    fn rescind_invite(self: @TContractState, challenge_id: u128);
    fn respond_invite(self: @TContractState, challenge_id: u128, blobert_id: u128);
    fn rescind_response(self: @TContractState, challenge_id: u128);
    fn reject_invite(self: @TContractState, challenge_id: u128);
    fn reject_response(self: @TContractState, challenge_id: u128);
    fn accept_response(self: @TContractState, challenge_id: u128) -> u128;
    fn commit_move(self: @TContractState, challenge_id: u128, hash: felt252);
    fn reveal_move(self: @TContractState, challenge_id: u128, move: Move, salt: felt252);
    fn forfeit(self: @TContractState, challenge_id: u128);
}
#[dojo::contract]
mod challenge_actions {
    use super::IChallengeActions;
    use starknet::ContractAddress;
    use blob_arena::{
        components::{combat::Move, world::World},
        systems::challenge::{Challenge, ChallengeSystemTrait},
    };
    #[abi(embed_v0)]
    impl ChallengeActionsImpl of IChallengeActions<ContractState> {
        fn send_invite(self: @ContractState, receiver: ContractAddress, blobert_id: u128) -> u128 {
            self.get_world().send_challenge_invite(receiver, blobert_id)
        }
        fn rescind_invite(self: @ContractState, challenge_id: u128) {
            let mut challenge = self._get_open_challenge(challenge_id);
            challenge.rescind_challenge_invite();
        }
        fn respond_invite(self: @ContractState, challenge_id: u128, blobert_id: u128) {
            let mut challenge = self._get_open_challenge(challenge_id);
            challenge.respond_challenge_invite(blobert_id);
        }
        fn rescind_response(self: @ContractState, challenge_id: u128) {
            let mut challenge = self._get_open_challenge(challenge_id);
            challenge.rescind_challenge_response();
        }
        fn reject_invite(self: @ContractState, challenge_id: u128) {
            let mut challenge = self._get_open_challenge(challenge_id);
            challenge.reject_challenge_invite();
        }
        fn reject_response(self: @ContractState, challenge_id: u128) {
            let mut challenge = self._get_open_challenge(challenge_id);
            challenge.reject_challenge_response();
        }
        fn accept_response(self: @ContractState, challenge_id: u128) -> u128 {
            let mut challenge = self._get_open_challenge(challenge_id);
            challenge.accept_challenge_response()
        }
        fn commit_move(self: @ContractState, challenge_id: u128, hash: felt252) {
            let challenge = self._get_running_challenge(challenge_id);
            challenge.commit_challenge_move(hash);
        }
        fn reveal_move(self: @ContractState, challenge_id: u128, move: Move, salt: felt252) {
            let challenge = self._get_running_challenge(challenge_id);
            challenge.reveal_challenge_move(move, salt);
        }
        fn forfeit(self: @ContractState, challenge_id: u128) {
            let challenge = self._get_running_challenge(challenge_id);
            challenge.forfeit_challenge();
        }
    }
    #[generate_trait]
    impl WorldImpl of WorldTrait {
        fn get_world(self: @ContractState) -> World {
            self.world_dispatcher.read()
        }
        fn _get_open_challenge(self: @ContractState, challenge_id: u128) -> Challenge {
            self.get_world().get_open_challenge(challenge_id)
        }
        fn _get_running_challenge(self: @ContractState, challenge_id: u128) -> Challenge {
            self.get_world().get_running_challenge(challenge_id)
        }
    }
}
