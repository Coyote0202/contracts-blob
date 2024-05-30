use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


#[starknet::interface]
trait IBlobertActions<TContractState> {
    fn mint(self: @TContractState, world: IWorldDispatcher, owner: ContractAddress) -> u128;
}

#[starknet::contract]
mod blobert_actions {
    use super::IBlobertActions;
    use starknet::ContractAddress;
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

    use blob_arena::{
        components::{
            arcade::{ArcadeBlobert, ArcadeBlobertTrait}, blobert::BlobertTrait, combat::Move,
            utils::{AB}
        },
        systems::arcade::blobert::{ArcadeBlobertWorldTrait}
    };


    #[storage]
    struct Storage {}

    #[abi(embed_v0)]
    impl BlobertActionsImpl of IBlobertActions<ContractState> {
        fn mint(self: @ContractState, world: IWorldDispatcher, owner: ContractAddress) -> u128 {
            world.mint_blobert(owner).id
        }
    }
}
