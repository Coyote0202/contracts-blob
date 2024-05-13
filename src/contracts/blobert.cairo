use starknet::ContractAddress;

#[starknet::interface]
trait IBlobertActions<TContractState> {
    fn mint(self: @TContractState, owner: ContractAddress) -> u128;
}

#[dojo::contract]
mod blobert_actions {
    use super::IBlobertActions;
    use starknet::ContractAddress;
    use blob_arena::{components::{blobert::BlobertTrait}, systems::blobert::BlobertWorldTrait};


    use blob_arena::{components::{combat::Move, utils::{AB}}, systems::{blobert::Blobert}};
    #[abi(embed_v0)]
    impl BlobertActionsImpl of IBlobertActions<ContractState> {
        fn mint(self: @ContractState, owner: ContractAddress) -> u128 {
            let world = self.world_dispatcher.read();
            world.mint_blobert(owner).id
        }
    }
}
