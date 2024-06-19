use starknet::{ContractAddress, get_caller_address};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use alexandria_math::BitShift;

use blob_arena::{utils::felt252_to_uuid, collections::blobert::external::{Seed, TokenTrait}};
use super::blobert::{ArcadeBlobertTrait, ArcadeBlobert};

const ARMOUR_COUNT: u8 = 17;
const JEWELRY_COUNT: u8 = 8;
const BACKGROUND_COUNT: u8 = 12;
const MASK_COUNT: u8 = 26;
const WEAPON_COUNT: u8 = 43;


fn generate_seed(randomness: felt252) -> Seed {
    let randomness: u256 = randomness.into();
    let background_count: u256 = BACKGROUND_COUNT.into();
    let armour_count: u256 = ARMOUR_COUNT.into();
    let jewelry_count: u256 = JEWELRY_COUNT.into();
    let weapon_count: u256 = WEAPON_COUNT.into();
    let mut mask_count: u256 = MASK_COUNT.into();

    let background: u8 = (randomness % background_count).try_into().unwrap();
    let armour: u8 = (BitShift::shr(randomness, 48) % armour_count).try_into().unwrap();

    // only allow the mask to be one of the first 8 masks 
    // where the armour is sheep wool or kigurumi
    if armour == 0 || armour == 1 {
        mask_count = 8;
    };

    let jewelry: u8 = (BitShift::shr(randomness, 96) % jewelry_count).try_into().unwrap();
    let mask: u8 = (BitShift::shr(randomness, 144) % mask_count).try_into().unwrap();
    let weapon: u8 = (BitShift::shr(randomness, 192) % weapon_count).try_into().unwrap();
    return Seed { background, armour, jewelry, mask, weapon };
}

#[generate_trait]
impl ArcadeBlobertMintImpl of ArcadeBlobertMintTrait {
    fn get_random_felt(self: @IWorldDispatcher) -> felt252 {
        0
    }
    fn mint_blobert(ref self: IWorldDispatcher) -> u256 {
        let caller = get_caller_address();
        let random = self.get_random_felt();
        let token_id = felt252_to_uuid(random);
        let seed = generate_seed(random);

        self
            .set_arcade_blobert(
                ArcadeBlobert { token_id, owner: caller, traits: TokenTrait::Regular(seed) }
            );
        token_id.into()
    }
}
