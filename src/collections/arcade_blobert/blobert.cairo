use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::collections::blobert::{external::TokenTrait};

#[dojo::model]
#[derive(Drop, Serde)]
struct ArcadeBlobert {
    #[key]
    token_id: u128,
    owner: ContractAddress,
    traits: TokenTrait
}


#[generate_trait]
impl ArcadeBlobertImpl of ArcadeBlobertTrait {
    fn set_arcade_blobert(ref self: IWorldDispatcher, arcade_blobert: ArcadeBlobert) {
        set!(self, (arcade_blobert,));
    }

    fn get_arcade_blobert<T, +TryInto<T, u128>>(
        self: @IWorldDispatcher, token_id: T
    ) -> ArcadeBlobert {
        let token_id: u128 = token_id.try_into().unwrap();
        get!(*self, token_id, ArcadeBlobert)
    }
    fn get_owner<T, +TryInto<T, u128>>(self: @IWorldDispatcher, token_id: T) -> ContractAddress {
        self.get_arcade_blobert(token_id).owner
    }

    fn get_traits<T, +TryInto<T, u128>>(self: @IWorldDispatcher, token_id: T) -> TokenTrait {
        self.get_arcade_blobert(token_id).traits
    }
}
