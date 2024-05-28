use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::components::combat::Move;

#[starknet::interface]
trait IChallengeActions<TContractState> {
    fn send_invite(
        self: @TContractState, world: IWorldDispatcher, receiver: ContractAddress, blobert_id: u128
    ) -> u128;
    fn rescind_invite(self: @TContractState, world: IWorldDispatcher, challenge_id: u128);
    fn respond_invite(
        self: @TContractState, world: IWorldDispatcher, challenge_id: u128, blobert_id: u128
    );
    fn rescind_response(self: @TContractState, world: IWorldDispatcher, challenge_id: u128);
    fn reject_invite(self: @TContractState, world: IWorldDispatcher, challenge_id: u128);
    fn reject_response(self: @TContractState, world: IWorldDispatcher, challenge_id: u128);
    fn accept_response(self: @TContractState, world: IWorldDispatcher, challenge_id: u128) -> u128;
    fn commit_move(
        self: @TContractState, world: IWorldDispatcher, challenge_id: u128, hash: felt252
    );
    fn reveal_move(
        self: @TContractState,
        world: IWorldDispatcher,
        challenge_id: u128,
        move: Move,
        salt: felt252
    );
}

#[starknet::contract]
mod challenge_actions {
    use super::IChallengeActions;
    use starknet::ContractAddress;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use blob_arena::{
        components::{combat::Move, world::World}, systems::challenge::ChallengeSystemTrait,
    };

    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl ChallengeActionsImpl of IChallengeActions<ContractState> {
        fn send_invite(
            self: @ContractState,
            world: IWorldDispatcher,
            receiver: ContractAddress,
            blobert_id: u128
        ) -> u128 {
            world.send_challenge_invite(receiver, blobert_id)
        }
        fn rescind_invite(self: @ContractState, world: IWorldDispatcher, challenge_id: u128) {
            world.rescind_challenge_invite(challenge_id);
        }
        fn respond_invite(
            self: @ContractState, world: IWorldDispatcher, challenge_id: u128, blobert_id: u128
        ) {
            world.respond_challenge_invite(challenge_id, blobert_id);
        }
        fn rescind_response(self: @ContractState, world: IWorldDispatcher, challenge_id: u128) {
            world.rescind_challenge_response(challenge_id);
        }
        fn reject_invite(self: @ContractState, world: IWorldDispatcher, challenge_id: u128) {
            world.reject_challenge_invite(challenge_id);
        }
        fn reject_response(self: @ContractState, world: IWorldDispatcher, challenge_id: u128) {
            world.reject_challenge_response(challenge_id);
        }
        fn accept_response(
            self: @ContractState, world: IWorldDispatcher, challenge_id: u128
        ) -> u128 {
            world.accept_challenge_response(challenge_id)
        }
        fn commit_move(
            self: @ContractState, world: IWorldDispatcher, challenge_id: u128, hash: felt252
        ) {
            world.commit_challenge_move(challenge_id, hash);
        }
        fn reveal_move(
            self: @ContractState,
            world: IWorldDispatcher,
            challenge_id: u128,
            move: Move,
            salt: felt252
        ) {
            world.reveal_challenge_move(challenge_id, move, salt);
        }
    }
}

