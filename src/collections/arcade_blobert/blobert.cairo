use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::collections::{
    blobert::{external::{TokenTrait, Seed}},
    arcade_blobert::models::ArcadeBlobert as ArcadeBlobertModel
};

#[derive(Drop, Serde, Copy)]
struct ArcadeBlobert {
    #[key]
    token_id: felt252,
    owner: ContractAddress,
    traits: TokenTrait
}


#[generate_trait]
impl ArcadeBlobertImpl of ArcadeBlobertTrait {
    fn set_arcade_blobert(
        self: IWorldDispatcher, token_id: felt252, owner: ContractAddress, traits: TokenTrait
    ) {
        let mut blobert = ArcadeBlobertModel {
            token_id, owner, is_custom: false, custom_id: 0, seed: Default::default()
        };
        match traits {
            TokenTrait::Regular(seed) => { blobert.seed = seed; },
            TokenTrait::Custom(custom_id) => {
                blobert.is_custom = true;
                blobert.custom_id = custom_id;
            }
        }
        set!(self, (blobert,));
    }

    fn get_arcade_blobert<T, +TryInto<T, felt252>>(
        self: @IWorldDispatcher, token_id: T
    ) -> ArcadeBlobert {
        let token_id: felt252 = token_id.try_into().unwrap();

        let blobert = get!(*self, token_id, ArcadeBlobertModel);
        let traits = if blobert.is_custom {
            TokenTrait::Custom(blobert.custom_id)
        } else {
            TokenTrait::Regular(blobert.seed)
        };
        ArcadeBlobert { token_id: blobert.token_id, owner: blobert.owner, traits }
    }
    fn get_arcade_blobert_owner<T, +TryInto<T, felt252>>(
        self: @IWorldDispatcher, token_id: T
    ) -> ContractAddress {
        self.get_arcade_blobert(token_id).owner
    }

    fn get_arcade_blobert_traits<T, +TryInto<T, felt252>>(
        self: @IWorldDispatcher, token_id: T
    ) -> TokenTrait {
        self.get_arcade_blobert(token_id).traits
    }
}
