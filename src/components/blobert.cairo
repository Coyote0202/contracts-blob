use token::erc721::interface::IERC721DispatcherTrait;
use core::traits::TryInto;
use starknet::{ContractAddress, class_hash::class_hash_const};
use core::fmt::{Display, Formatter, Error};
use alexandria_math::BitShift;

use blob_arena::{
    components::{
        arcade::ArcadeBlobert, stats::{Stats, StatsTrait},
        traits::{
            background::{Background, BACKGROUND_COUNT}, armour::{Armour, ARMOUR_COUNT},
            mask::{Mask, MASK_COUNT}, jewelry::{Jewelry, JEWELRY_COUNT},
            weapon::{Weapon, WEAPON_COUNT},
        },
        utils::DisplayImplT,
    },
    external::blobert::{IBlobertDispatcherTrait, IBlobertDispatcher, TokenTrait, Seed}
};
use token::{erc721::interface::{IERC721Dispatcher, IERC721}};


#[dojo::model]
#[derive(Copy, Drop, Print, Serde)]
struct Blobert {
    #[key]
    id: u128,
    owner: ContractAddress,
    traits: TokenTrait,
    stats: Stats,
    arcade: bool,
}

fn is_arcade_from_id<T, +Into<T, u256>>(id: T) -> bool {
    id.into() > 4844_u256
}

impl SeedIntoTraits of Into<Seed, Traits> {
    fn into(self: Seed) -> Traits {
        Traits {
            background: self.background.into(),
            armour: self.armour.into(),
            mask: self.mask.into(),
            jewelry: self.jewelry.into(),
            weapon: self.weapon.into(),
        }
    }
}


impl TraitsIntoSeed of Into<Traits, Seed> {
    fn into(self: Traits) -> Seed {
        Seed {
            background: self.background.into(),
            armour: self.armour.into(),
            mask: self.mask.into(),
            jewelry: self.jewelry.into(),
            weapon: self.weapon.into(),
        }
    }
}


impl TraitsIntoTokenTrait of Into<Traits, TokenTrait> {
    fn into(self: Traits) -> TokenTrait {
        TokenTrait::Regular(self.into())
    }
}

impl TokenTraitIntoTraits of Into<TokenTrait, Traits> {
    fn into(self: TokenTrait) -> Traits {
        match self {
            TokenTrait::Regular(seed) => seed.into(),
            TokenTrait::Custom(_index) => panic!("Custom tokens not implemented yet"),
        }
    }
}


#[derive(Copy, Drop, Print, Serde, Introspect)]
struct Traits {
    background: Background,
    armour: Armour,
    mask: Mask,
    jewelry: Jewelry,
    weapon: Weapon,
}


impl OutcomeIntoByteArray of Into<Traits, ByteArray> {
    fn into(self: Traits) -> ByteArray {
        let background: ByteArray = self.background.into();
        let armour: ByteArray = self.armour.into();
        let mask: ByteArray = self.mask.into();
        let jewelry: ByteArray = self.jewelry.into();
        let weapon: ByteArray = self.weapon.into();
        format!("{} Mask, {}, {}, {}, {} Background", mask, jewelry, armour, weapon, background)
    }
}
impl DisplayImplTraits = DisplayImplT<Traits>;


fn calculate_stats(traits: Traits) -> Stats {
    let Traits { background, armour, mask, jewelry, weapon, } = traits;
    let (b_stats, a_stats, m_stats, j_stats, mut w_stats) = (
        background.stats(), armour.stats(), mask.stats(), jewelry.stats(), weapon.stats()
    );

    return (b_stats + j_stats + w_stats + a_stats + m_stats);
}

impl TraitsIntoStats of Into<Traits, Stats> {
    fn into(self: Traits) -> Stats {
        calculate_stats(self)
    }
}

impl TokenTraitIntoSeed of Into<TokenTrait, Seed> {
    fn into(self: TokenTrait) -> Seed {
        match self {
            TokenTrait::Regular(seed) => { seed },
            TokenTrait::Custom(_index) => panic!("Custom tokens not implemented yet"),
        }
    }
}

impl TokenTraitIntoStats of Into<TokenTrait, Stats> {
    fn into(self: TokenTrait) -> Stats {
        Into::<Traits, Stats>::into(self.into())
    }
}


impl SeedIntoTokenTrait of Into<Seed, TokenTrait> {
    fn into(self: Seed) -> TokenTrait {
        Into::<Traits, TokenTrait>::into(self.into())
    }
}

fn generate_seed(randomness: u256,) -> Seed {
    let mut mask_count: u256 = WEAPON_COUNT.into();

    let background: u8 = (randomness % BACKGROUND_COUNT.into()).try_into().unwrap();
    let armour: u8 = (BitShift::shr(randomness, 48) % ARMOUR_COUNT.into()).try_into().unwrap();

    // only allow the mask to be one of the first 8 masks 
    // where the armour is sheep wool or kigurumi
    if armour == 0 || armour == 1 {
        mask_count = 8;
    };

    let jewelry: u8 = (BitShift::shr(randomness, 96) % JEWELRY_COUNT.into()).try_into().unwrap();
    let mask: u8 = (BitShift::shr(randomness, 144) % mask_count).try_into().unwrap();
    let weapon: u8 = (BitShift::shr(randomness, 192) % WEAPON_COUNT.into()).try_into().unwrap();
    return Seed { background, armour, jewelry, mask, weapon };
}

fn generate_traits(seed: u256) -> Traits {
    let background_count: u256 = BACKGROUND_COUNT.into();
    let armour_count: u256 = ARMOUR_COUNT.into();
    let jewelry_count: u256 = JEWELRY_COUNT.into();
    let weapon_count: u256 = WEAPON_COUNT.into();
    let mut mask_count: u256 = MASK_COUNT.into();
    let mut m_seed = seed;
    let background: u8 = (m_seed % background_count).try_into().unwrap();
    m_seed /= 0x100;
    let armour: u8 = (m_seed % armour_count).try_into().unwrap();
    m_seed /= 0x100;
    // only allow the mask to be one of the first 8 masks 
    // where the armour is sheep wool or kigurumi
    if armour == 0 || armour == 1 {
        mask_count = 8;
    };

    let jewelry: u8 = (m_seed % jewelry_count).try_into().unwrap();
    m_seed /= 0x100;

    let mask: u8 = (m_seed % mask_count).try_into().unwrap();
    m_seed /= 0x100;

    let weapon: u8 = (m_seed % weapon_count).try_into().unwrap();
    Traits {
        background: background.into(),
        armour: armour.into(),
        mask: mask.into(),
        jewelry: jewelry.into(),
        weapon: weapon.into(),
    }
}


#[generate_trait]
impl BlobertImpl of BlobertTrait {
    fn check_owner(self: Blobert, player: ContractAddress) -> bool {
        return self.owner == player;
    }
    fn assert_owner(self: Blobert, player: ContractAddress) {
        assert(self.check_owner(player), 'Not Blobert Owner');
    }
    fn assert_is_correct_league(self: Blobert, arcade: bool) {
        let string = if self.arcade {
            'Arcade Bloberts not allowed'
        } else {
            'Only Arcade Bloberts allowed'
        };

        assert(self.arcade == arcade, string);
    }
    fn assert_is_playable(self: Blobert, player: ContractAddress, arcade: bool) {
        self.assert_is_correct_league(arcade);
        self.assert_owner(player);
    }
}
