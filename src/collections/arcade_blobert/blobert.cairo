use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::collections::blobert::{external::TokenTrait};

#[dojo::model]
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
        set!(self, ArcadeBlobert { token_id, owner, traits });
    }

    fn get_arcade_blobert<T, +TryInto<T, felt252>>(
        self: @IWorldDispatcher, token_id: T
    ) -> ArcadeBlobert {
        let token_id: felt252 = token_id.try_into().unwrap();
        get!(*self, token_id, ArcadeBlobert)
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
