use starknet::ContractAddress;
use blob_arena::{
    components::blobert::{
        Blobert, Stats, Traits, TokenTraitIntoStats, SeedIntoTokenTrait, generate_seed
    },
    external::blobert::{TokenTrait}
};

#[dojo::model]
#[derive(Copy, Drop, Print, Serde)]
struct ArcadeBlobertContract {
    #[key]
    key: bool,
    minted: u128,
}

#[dojo::model]
#[derive(Copy, Drop, Print, Serde)]
struct ArcadeBlobert {
    #[key]
    id: u128,
    owner: ContractAddress,
    traits: TokenTrait,
}

impl ArcadeBlobertIntoBlobert of Into<ArcadeBlobert, Blobert> {
    fn into(self: ArcadeBlobert) -> Blobert {
        Blobert {
            id: self.id,
            owner: self.owner,
            stats: self.traits.into(),
            traits: self.traits,
            arcade: true,
        }
    }
}

#[generate_trait]
impl ArcadeBlobertImpl of ArcadeBlobertTrait {
    fn new(id: u128, owner: ContractAddress, randomness: u256) -> ArcadeBlobert {
        return ArcadeBlobert { id, owner, traits: generate_seed(randomness).into() };
    }
}

