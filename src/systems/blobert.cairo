use blob_arena::{
    components::{blobert::{Blobert, BlobertTrait}, world::World}, utils::{uuid, RandomTrait}
};
use dojo::world::{IWorldDispatcherTrait};
use starknet::{ContractAddress};

#[generate_trait]
impl BlobertWorldImpl of BlobertWorldTrait {
    fn mint_blobert(self: World, owner: ContractAddress) -> Blobert {
        let id = uuid(self);
        let mut random = RandomTrait::new();
        let seed = random.next();
        let blobert = BlobertTrait::new(id, owner, seed);
        set!(self, (blobert,));
        blobert
    }
    fn get_blobert(self: World, blobert_id: u128) -> Blobert {
        let blobert: Blobert = get!(self, (blobert_id), Blobert);
        assert(blobert.owner.is_non_zero(), 'Blobert not found');
        blobert
    }
    fn transfer_blobert(self: World, ref blobert: Blobert, owner: ContractAddress) {
        blobert.owner = owner;
        set!(self, (blobert,));
    }
    fn assert_blobert_owner(self: World, blobert_id: u128, player: ContractAddress) {
        let blobert = self.get_blobert(blobert_id);
        blobert.assert_owner(player);
    }
}
