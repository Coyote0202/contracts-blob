use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{components::combat::Move, systems::challenge::{Challenge, ChallengeSystemTrait}};

#[starknet::interface]
trait IChallengeActions<TContractState> {
    fn send_invite(
        self: @TContractState,
        world: IWorldDispatcher,
        receiver: ContractAddress,
        blobert_id: u128,
        phase_time: u64,
        arcade: bool,
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
    fn forfeit(self: @TContractState, world: IWorldDispatcher, challenge_id: u128);
    fn kick_inactive_player(self: @TContractState, world: IWorldDispatcher, challenge_id: u128);
}

#[starknet::contract]
mod challenge_actions {
    use super::{IChallengeActions};
    use starknet::ContractAddress;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use blob_arena::{
        components::{combat::Move, world::World},
        systems::challenge::{Challenge, ChallengeSystemTrait},
    };

    #[storage]
    struct Storage {}


    #[abi(embed_v0)]
    impl ChallengeActionsImpl of IChallengeActions<ContractState> {
        fn send_invite(
            self: @ContractState,
            world: IWorldDispatcher,
            receiver: ContractAddress,
            blobert_id: u128,
            phase_time: u64,
            arcade: bool,
        ) -> u128 {
            world.send_challenge_invite(receiver, blobert_id, phase_time, arcade)
        }
        fn rescind_invite(self: @ContractState, world: IWorldDispatcher, challenge_id: u128) {
            let mut challenge = world.get_open_challenge(challenge_id);
            challenge.rescind_challenge_invite();
        }
        fn respond_invite(
            self: @ContractState, world: IWorldDispatcher, challenge_id: u128, blobert_id: u128
        ) {
            let mut challenge = world.get_open_challenge(challenge_id);
            challenge.respond_challenge_invite(blobert_id);
        }
        fn rescind_response(self: @ContractState, world: IWorldDispatcher, challenge_id: u128) {
            let mut challenge = world.get_open_challenge(challenge_id);
            challenge.rescind_challenge_response();
        }
        fn reject_invite(self: @ContractState, world: IWorldDispatcher, challenge_id: u128) {
            let mut challenge = world.get_open_challenge(challenge_id);
            challenge.reject_challenge_invite();
        }
        fn reject_response(self: @ContractState, world: IWorldDispatcher, challenge_id: u128) {
            let mut challenge = world.get_open_challenge(challenge_id);
            challenge.reject_challenge_response();
        }
        fn accept_response(
            self: @ContractState, world: IWorldDispatcher, challenge_id: u128
        ) -> u128 {
            let mut challenge = world.get_open_challenge(challenge_id);
            challenge.accept_challenge_response()
        }
        fn commit_move(
            self: @ContractState, world: IWorldDispatcher, challenge_id: u128, hash: felt252
        ) {
            let challenge = world.get_running_challenge(challenge_id);
            challenge.commit_challenge_move(hash);
        }
        fn reveal_move(
            self: @ContractState,
            world: IWorldDispatcher,
            challenge_id: u128,
            move: Move,
            salt: felt252
        ) {
            let challenge = world.get_running_challenge(challenge_id);
            challenge.reveal_challenge_move(move, salt);
        }
        fn forfeit(self: @ContractState, world: IWorldDispatcher, challenge_id: u128) {
            let challenge = world.get_running_challenge(challenge_id);
            challenge.forfeit_challenge();
        }
        fn kick_inactive_player(self: @ContractState, world: IWorldDispatcher, challenge_id: u128) {
            let challenge = world.get_running_challenge(challenge_id);
            challenge.kick_inactive_challenge_player();
        }
    }
}
