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
        components::{combat::Move, world::World}, systems::challenge::ChallengeSystemTrait,
    };
    #[abi(embed_v0)]
    impl ChallengeActionsImpl of IChallengeActions<ContractState> {
        fn send_invite(self: @ContractState, receiver: ContractAddress, blobert_id: u128) -> u128 {
            self.get_world().send_challenge_invite(receiver, blobert_id)
        }
        fn rescind_invite(self: @ContractState, challenge_id: u128) {
            self.get_world().rescind_challenge_invite(challenge_id);
        }
        fn respond_invite(self: @ContractState, challenge_id: u128, blobert_id: u128) {
            self.get_world().respond_challenge_invite(challenge_id, blobert_id);
        }
        fn rescind_response(self: @ContractState, challenge_id: u128) {
            self.get_world().rescind_challenge_response(challenge_id);
        }
        fn reject_invite(self: @ContractState, challenge_id: u128) {
            self.get_world().reject_challenge_invite(challenge_id);
        }
        fn reject_response(self: @ContractState, challenge_id: u128) {
            self.get_world().reject_challenge_response(challenge_id);
        }
        fn accept_response(self: @ContractState, challenge_id: u128) -> u128 {
            self.get_world().accept_challenge_response(challenge_id)
        }
        fn commit_move(self: @ContractState, challenge_id: u128, hash: felt252) {
            self.get_world().commit_challenge_move(challenge_id, hash);
        }
        fn reveal_move(self: @ContractState, challenge_id: u128, move: Move, salt: felt252) {
            self.get_world().reveal_challenge_move(challenge_id, move, salt);
        }
        fn forfeit(self: @ContractState, challenge_id: u128) {
            self.get_world().forfeit_challenge(challenge_id);
        }
    }
    #[generate_trait]
    impl WorldImpl of WorldTrait {
        fn get_world(self: @ContractState) -> World {
            self.world_dispatcher.read()
        }
    }
}
