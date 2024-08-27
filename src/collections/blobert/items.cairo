use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use super::external::{Seed, TokenTrait};
use blob_arena::{
    core::TTupleSize5, utils::{value_to_uuid, HashStateTrait},
    components::{stats::{Stats}, item::{ItemTrait, ItemsTrait, AttackInput}},
};
use core::hash::into_felt252_based;
type SeedIds = TTupleSize5<u128>;

struct BlobertTraitsSeed {
    background: u128,
    armour: u128,
    jewelry: u128,
    mask: u128,
    weapon: u128,
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
    custom: bool,
    #[key]
    blobert_trait: BlobertTrait,
    #[key]
    blobert_trait_id: u8,
    item_id: u128,
}


fn get_trait_id(blobert_trait: BlobertTrait, trait_id: u8) -> u128 {
    value_to_uuid(('seed', blobert_trait, trait_id))
}

fn get_custom_trait_id(blobert_trait: BlobertTrait, custom_id: u8) -> u128 {
    value_to_uuid(('custom', blobert_trait, custom_id))
}

#[generate_trait]
impl BlobertItems of BlobertItemsTrait {
    fn set_seed_item_id(
        self: IWorldDispatcher, blobert_trait: BlobertTrait, blobert_trait_id: u8, item_id: u128
    ) {
        set!(self, ItemMap { custom: false, blobert_trait, blobert_trait_id, item_id, });
    }
    fn set_custom_item_id(
        self: IWorldDispatcher, blobert_trait: BlobertTrait, blobert_trait_id: u8, item_id: u128
    ) {
        set!(self, ItemMap { custom: true, blobert_trait, blobert_trait_id, item_id, });
    }
    fn get_seed_item_id(
        self: @IWorldDispatcher, blobert_trait: BlobertTrait, blobert_trait_id: u8
    ) -> u128 {
        get!(*self, (false, blobert_trait, blobert_trait_id), ItemMap).item_id
    }
    fn get_custom_item_id(
        self: @IWorldDispatcher, blobert_trait: BlobertTrait, blobert_trait_id: u8
    ) -> u128 {
        get!(*self, (false, blobert_trait, blobert_trait_id), ItemMap).item_id
    }
    fn get_seed_item_ids(self: @IWorldDispatcher, traits: Seed) -> SeedIds {
        (
            self.get_seed_item_id(BlobertTrait::Background, traits.background),
            self.get_seed_item_id(BlobertTrait::Armour, traits.armour),
            self.get_seed_item_id(BlobertTrait::Jewelry, traits.jewelry),
            self.get_seed_item_id(BlobertTrait::Mask, traits.mask),
            self.get_seed_item_id(BlobertTrait::Weapon, traits.weapon),
        )
    }
    fn get_custom_item_ids(self: @IWorldDispatcher, custom_id: u8) -> SeedIds {
        (
            self.get_custom_item_id(BlobertTrait::Background, custom_id),
            self.get_custom_item_id(BlobertTrait::Armour, custom_id),
            self.get_custom_item_id(BlobertTrait::Jewelry, custom_id),
            self.get_custom_item_id(BlobertTrait::Mask, custom_id),
            self.get_custom_item_id(BlobertTrait::Weapon, custom_id),
        )
    }
    fn get_item_ids(self: @IWorldDispatcher, blobert_trait: TokenTrait) -> SeedIds {
        match blobert_trait {
            TokenTrait::Regular(seed) => self.get_seed_item_ids(seed),
            TokenTrait::Custom(custom_id) => self.get_custom_item_ids(custom_id),
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
