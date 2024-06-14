use core::array::ArrayTrait;
use starknet::ContractAddress;
use super::interface::{CollectionInterfaceTrait, owner_of_erc721};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::external::blobert::Seed;


#[dojo::model]
#[derive(Drop, Serde)]
struct ArcadeBlobert {
    #[key]
    token_id_high: u128,
    token_id_low: u128,
    owner: ContractAddress,
    traits: Seed
}

#[derive(Drop, Serde, Copy)]
struct ArcadeBlobertCollection {
    world: IWorldDispatcher,
}

fn new_collection(world: IWorldDispatcher) -> ArcadeBlobertCollection {
    ArcadeBlobertCollection { world }
}


impl ArcadeBlobertCollectionImpl of CollectionInterfaceTrait<ArcadeBlobertCollection> {
    fn owner_of(self: ArcadeBlobertCollection, token_id: u256) -> ContractAddress {
        get!(self.world, (token_id.high, token_id.low), ArcadeBlobert).owner
    }
    fn get_items(self: ArcadeBlobertCollection, token_id: u256) -> Array<u128> {
        ArrayTrait::new()
    }
}
