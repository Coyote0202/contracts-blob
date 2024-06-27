use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use super::external::{Seed, TokenTrait};
use blob_arena::{core::TTupleSize5, utils::{value_to_uuid, HashStateTrait}};
use core::hash::into_felt252_based;
type SeedIds = TTupleSize5<u128>;

struct BlobertTraitsSeed {
    background: u128,
    armour: u128,
    jewelry: u128,
    mask: u128,
    weapon: u128,
}

#[derive(Copy, Drop, Print, Serde, SerdeLen, PartialEq, Introspect)]
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

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct ItemMap {
    #[key]
    blobert_trait_id: u128,
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
        self: IWorldDispatcher, blobert_trait: BlobertTrait, trait_id: u8, item_id: u128
    ) {
        set!(self, ItemMap { blobert_trait_id: get_trait_id(blobert_trait, trait_id), item_id, });
    }
    fn set_custom_item_id(
        self: IWorldDispatcher, blobert_trait: BlobertTrait, custom_id: u8, item_id: u128
    ) {
        set!(
            self,
            ItemMap { blobert_trait_id: get_custom_trait_id(blobert_trait, custom_id), item_id, }
        );
    }
    fn get_seed_item_id(
        self: @IWorldDispatcher, blobert_trait: BlobertTrait, trait_id: u8
    ) -> u128 {
        get!(*self, get_trait_id(blobert_trait, trait_id), ItemMap).item_id
    }
    fn get_custom_item_id(
        self: @IWorldDispatcher, blobert_trait: BlobertTrait, custom_id: u8
    ) -> u128 {
        get!(*self, get_custom_trait_id(blobert_trait, custom_id), ItemMap).item_id
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
