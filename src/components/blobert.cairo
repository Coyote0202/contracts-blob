use core::traits::TryInto;
use starknet::ContractAddress;
use core::fmt::{Display, Formatter, Error};

use blob_arena::components::{
    stats::{Stats, StatsTrait}, background::{Background, BACKGROUND_COUNT},
    armour::{Armour, ARMOUR_COUNT}, mask::{Mask, MASK_COUNT}, jewelry::{Jewelry, JEWELRY_COUNT},
    weapon::{Weapon, WEAPON_COUNT}, utils::DisplayImplT,
};

#[derive(Model, Copy, Drop, Print, Serde)]
struct Blobert {
    #[key]
    id: u128,
    owner: ContractAddress,
    traits: Traits,
    stats: Stats,
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
    fn new(id: u128, owner: ContractAddress, seed: u256) -> Blobert {
        let traits = generate_traits(seed);
        let stats = calculate_stats(traits);
        return Blobert { id, owner, traits, stats };
    }
    fn check_owner(self: Blobert, player: ContractAddress) -> bool {
        return self.owner == player;
    }
    fn assert_owner(self: Blobert, player: ContractAddress) {
        assert(self.check_owner(player), 'Not Blobert Owner');
    }
}
