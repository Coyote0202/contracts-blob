use starknet::ContractAddress;

#[starknet::interface]
trait ILobbyActions<TContractState> {
    fn create(self: @TContractState, blobert_id: u128) -> u128;
    fn join(self: @TContractState, lobby_id: u128, blobert_id: u128);
    fn leave(self: @TContractState);
    fn close(self: @TContractState);
}

#[dojo::contract]
mod lobby_actions {
    use super::ILobbyActions;
    use starknet::ContractAddress;
    use blob_arena::{systems::lobby::LobbyTrait};


    use blob_arena::{components::{combat::Move, utils::{AB}}, systems::{blobert::Blobert}};
    #[abi(embed_v0)]
    impl LobbyActionsImpl of ILobbyActions<ContractState> {
        fn create(self: @ContractState, blobert_id: u128) -> u128 {
            self.world_dispatcher.read().create_lobby(blobert_id)
        }
        fn join(self: @ContractState, lobby_id: u128, blobert_id: u128) {
            self.world_dispatcher.read().join_lobby(lobby_id, blobert_id)
        }
        fn leave(self: @ContractState) {
            self.world_dispatcher.read().leave_lobby()
        }
        fn close(self: @ContractState) {
            self.world_dispatcher.read().close_lobby()
        }
    }
}
