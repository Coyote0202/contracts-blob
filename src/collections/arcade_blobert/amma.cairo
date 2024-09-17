use starknet::{ContractAddress, get_caller_address};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    core::TTupleSize5, utils::{value_to_uuid, HashStateTrait}, world::WorldTrait,
    collections::{blobert::{external::TokenTrait}, arcade_blobert::blobert::ArcadeBlobert},
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
    fn mint_amma_blobert(self: IWorldDispatcher, owner: ContractAddress, fighter_id: u8) -> u128 {
        let custom_id = AMMABlobertStore::get_custom_id(self, fighter_id);
        let token_id = value_to_uuid((owner, custom_id));

        ArcadeBlobert { token_id, owner, traits: TokenTrait::Custom(custom_id) }.set(self);
        token_id
    }
    fn set_amma_blobert(self: IWorldDispatcher, fighter_id: u8, name: ByteArray, custom_id: u8) {
        self.assert_caller_is_owner();
        AMMABlobert { fighter_id, name, custom_id }.set(self);
    }
}
