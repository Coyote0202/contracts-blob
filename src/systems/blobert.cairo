use core::traits::Into;
use token::erc721::interface::IERC721DispatcherTrait;
use starknet::{ContractAddress};
use token::{erc721::interface::{IERC721Dispatcher, IERC721}};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use blob_arena::{
    external::blobert::{
        get_blobert_dispatchers, get_erc271_dispatcher, IBlobertDispatcherTrait, TokenTrait, Seed
    },
    components::{
        arcade::ArcadeBlobert, stats::{Stats, StatsTrait},
        blobert::{Blobert, TokenTraitIntoStats, is_arcade_from_id}
    },
    systems::arcade::blobert::ArcadeBlobertWorldTrait,
};


fn load_blobert(id: u128) -> Blobert {
    let (erc721_dispatcher, blobert_dispatcher) = get_blobert_dispatchers();
    let id_u256: u256 = id.into();
    let token_traits = blobert_dispatcher.traits(id_u256);
    let owner = erc721_dispatcher.owner_of(id_u256);
    Blobert { id, owner, traits: token_traits, stats: token_traits.into(), arcade: false, }
}


#[generate_trait]
impl BlobertSystemImpl of BlobertSystemTrait {
    fn init_blobert(self: IWorldDispatcher, id: u128) -> Blobert {
        let blobert = if is_arcade_from_id(id) {
            self.load_arcade_blobert(id).into()
        } else {
            load_blobert(id)
        };
        set!(self, (blobert,));
        blobert
    }

    fn load_blobert(self: IWorldDispatcher, id: u128) -> Blobert {
        let blobert: Blobert = get!(self, id, Blobert);
        assert(blobert.owner.is_non_zero(), 'Blobert does not exist');
        blobert
    }


    fn transfer(self: Blobert, from: ContractAddress, to: ContractAddress) {
        let erc721_dispatcher = get_erc271_dispatcher();
        erc721_dispatcher.transfer_from(from, to, self.id.into());
        self.owner = to;
    }
}

