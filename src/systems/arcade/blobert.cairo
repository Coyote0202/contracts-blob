use blob_arena::{
    components::{
        arcade::{ArcadeBlobert, ArcadeBlobertTrait}, blobert::{BlobertTrait}, world::World
    },
    utils::{uuid, RandomTrait}
};
use dojo::world::{IWorldDispatcherTrait};
use starknet::{ContractAddress};
use core::poseidon::poseidon_hash_span;



const MIN_BLOBERT_ID: u128 = 65535;
#[generate_trait]
impl ArcadeBlobertWorldImpl of ArcadeBlobertWorldTrait {
    fn mint_blobert(self: World, owner: ContractAddress) -> ArcadeBlobert {
        self.contract_address
        get!(world, self.contract_address, );
        // let id = 
        let mut random = RandomTrait::new();
        let seed = random.next();
        let blobert = ArcadeBlobertTrait::new(id, owner, seed);
        set!(self, (blobert,));
        blobert
    }

    fn load_arcade_blobert(self: World, blobert_id: u128) -> ArcadeBlobert {
        let blobert: ArcadeBlobert = get!(self, (blobert_id), ArcadeBlobert);
        assert(blobert.owner.is_non_zero(), 'Blobert not found');
        blobert
    }
}


