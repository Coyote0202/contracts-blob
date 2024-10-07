use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use super::external::{Seed, TokenTrait};
use blob_arena::{
    core::TTupleSize5, utils::{value_to_uuid, HashStateTrait},
    components::{stats::{Stats}, item::{ItemTrait, ItemsTrait, AttackInput}},
};
use core::hash::into_felt252_based;
type SeedIds = TTupleSize5<u128>;

const SEED_TRAIT_TYPE: felt252 = 'seed';
const CUSTOM_TRAIT_TYPE: felt252 = 'custom';

struct BlobertTraitsSeed {
    background: u128,
    armour: u128,
    jewelry: u128,
    mask: u128,
    weapon: u128,
}

impl U8IntoBlobertSeedImpl of Into<u8, Seed> {
    fn into(self: u8) -> Seed {
        Seed { background: self, armour: self, jewelry: self, mask: self, weapon: self, }
    }
}

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum BlobertTrait {
    Background,
    Armour,
    Jewelry,
    Mask,
    Weapon,
}

impl HashBlobertTrait<S, +HashStateTrait<S>, +Drop<S>> =
    into_felt252_based::HashImpl<BlobertTrait, S>;

impl BlobertTraitIntoFelt252 of Into<BlobertTrait, felt252> {
    fn into(self: BlobertTrait) -> felt252 {
        match self {
            BlobertTrait::Background => 'background',
            BlobertTrait::Armour => 'armour',
            BlobertTrait::Jewelry => 'jewelry',
            BlobertTrait::Mask => 'mask',
            BlobertTrait::Weapon => 'weapon',
        }
    }
}

impl U8IntoBlobertTrait of Into<u8, BlobertTrait> {
    fn into(self: u8) -> BlobertTrait {
        match self {
            0 => BlobertTrait::Background,
            1 => BlobertTrait::Armour,
            2 => BlobertTrait::Jewelry,
            3 => BlobertTrait::Mask,
            4 => BlobertTrait::Weapon,
            _ => panic!("Invalid BlobertTrait"),
        }
    }
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct ItemMap {
    #[key]
    trait_type: felt252,
    #[key]
    blobert_trait: BlobertTrait,
    #[key]
    blobert_trait_id: u8,
    item_id: u128,
}

#[generate_trait]
impl BlobertItems of BlobertItemsTrait {
    fn set_item_id(
        self: IWorldDispatcher,
        trait_type: felt252,
        blobert_trait: BlobertTrait,
        blobert_trait_id: u8,
        item_id: u128
    ) {
        ItemMap { trait_type, blobert_trait, blobert_trait_id, item_id, }.set(self);
    }
    fn get_item_id(
        self: @IWorldDispatcher,
        trait_type: felt252,
        blobert_trait: BlobertTrait,
        blobert_trait_id: u8
    ) -> u128 {
        ItemMapStore::get_item_id(*self, trait_type, blobert_trait, blobert_trait_id)
    }
    fn get_seed_item_ids(self: @IWorldDispatcher, trait_type: felt252, traits: Seed) -> SeedIds {
        (
            self.get_item_id(trait_type, BlobertTrait::Background, traits.background),
            self.get_item_id(trait_type, BlobertTrait::Armour, traits.armour),
            self.get_item_id(trait_type, BlobertTrait::Jewelry, traits.jewelry),
            self.get_item_id(trait_type, BlobertTrait::Mask, traits.mask),
            self.get_item_id(trait_type, BlobertTrait::Weapon, traits.weapon),
        )
    }
    fn get_item_ids(self: @IWorldDispatcher, blobert_trait: TokenTrait) -> SeedIds {
        match blobert_trait {
            TokenTrait::Regular(seed) => self.get_seed_item_ids(SEED_TRAIT_TYPE, seed),
            TokenTrait::Custom(custom_id) => self
                .get_seed_item_ids(CUSTOM_TRAIT_TYPE, custom_id.into()),
        }
    }
}

#[generate_trait]
impl BlobertStatsImpl of BlobertStatsTrait {
    fn get_blobert_item_ids(self: @IWorldDispatcher, blobert_trait: TokenTrait) -> Array<u128> {
        let (background, armour, jewelry, mask, weapon) = self.get_item_ids(blobert_trait);
        array![background, armour, jewelry, mask, weapon]
    }
    fn get_blobert_stats(self: @IWorldDispatcher, blobert_trait: TokenTrait) -> Stats {
        self.get_items(self.get_blobert_item_ids(blobert_trait).span()).get_stats()
    }
    fn get_blobert_health(self: @IWorldDispatcher, blobert_trait: TokenTrait) -> u8 {
        let stats = self.get_blobert_stats(blobert_trait);
        if stats.defense > 155 {
            255
        } else {
            100 + stats.defense
        }
    }
    fn blobert_has_attack(
        self: @IWorldDispatcher, blobert_trait: TokenTrait, item_id: u128, attack_id: u128
    ) -> bool {
        let mut item_ids = self.get_blobert_item_ids(blobert_trait);
        let mut has = false;
        loop {
            match item_ids.pop_front() {
                Option::Some(id) => { if id == item_id {
                    has = true;
                    break;
                } },
                Option::None => { break; },
            }
        };
        if has {
            self.check_has_attack(item_id, attack_id)
        } else {
            false
        }
    }
}
