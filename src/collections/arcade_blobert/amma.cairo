use starknet::{ContractAddress, get_caller_address};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    core::TTupleSize5, utils::{hash_value, HashStateTrait}, world::WorldTrait,
    collections::{blobert::{external::TokenTrait}, arcade_blobert::blobert::ArcadeBlobertTrait},
};

#[dojo::model]
#[derive(Drop, Serde)]
struct AMMABlobert {
    #[key]
    fighter_id: u8,
    name: ByteArray,
    custom_id: u8,
}

#[generate_trait]
impl AMMABlobertImpl of AMMABlobertTrait {
    fn mint_amma_blobert(
        self: IWorldDispatcher, owner: ContractAddress, fighter_id: u8
    ) -> felt252 {
        let custom_id = AMMABlobertStore::get_custom_id(self, fighter_id);
        let token_id = hash_value((owner, custom_id));
        self.set_arcade_blobert(token_id, owner, TokenTrait::Custom(custom_id));
        token_id
    }
    fn set_amma_blobert(self: IWorldDispatcher, fighter_id: u8, name: ByteArray, custom_id: u8) {
        self.assert_caller_is_owner();
        AMMABlobert { fighter_id, name, custom_id }.set(self);
    }
}
