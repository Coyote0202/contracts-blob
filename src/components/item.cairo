use alexandria_data_structures::array_ext::ArrayTraitExt;
use core::array::ArrayTrait;
use starknet::{ContractAddress};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    models::{ItemModel, HasAttack},
    components::{stats::Stats, attack::{Attack, AttackTrait}, utils::{IdTrait, IdsTrait, TIdsImpl}}
};

#[derive(Drop, Serde, Copy)]
struct Item {
    id: u128,
    stats: Stats,
}

// impl ByteArrayCopyImpl of Copy<ByteArray>;
// impl ItemCopyImpl of Copy<Item>;

impl ItemIdImpl of IdTrait<Item> {
    fn id(self: Item) -> u128 {
        self.id
    }
}

impl ItemIdsImpl = TIdsImpl<Item>;

#[generate_trait]
impl ItemsImpl of ItemsTrait {
    // fn get_attacks(self: Span<Item>) -> Array<Attack> {
    //     let mut attacks: Array<Attack> = ArrayTrait::new();
    //     let (len, mut n) = (self.len(), 0_usize);
    //     while n < len {
    //         let span = self.at(n).attacks.span();
    //         attacks.append_span(span);
    //         n += 1;
    //     };
    //     attacks
    // }
    fn get_stats(self: Span<Item>) -> Stats {
        let mut stats: Stats = 0_u8.into();
        let (len, mut n) = (self.len(), 0_usize);
        while n < len {
            stats = stats + *self.at(n).stats;
            n += 1;
        };
        stats
    }
}

// impl ItemIntoItemModel of Into<Item, ItemModel> {
//     fn into(self: Item) -> ItemModel {
//         let mut attack_ids: Array<u128> = ArrayTrait::new();
//         let (len, mut n) = (attack_ids.len(), 0_usize);
//         while (n < len) {
//             attack_ids.append(*self.attacks.at(n).id);
//             n += 1;
//         };
//         ItemModel { id: self.id, name: self.name, stats: self.stats, attacks: attack_ids }
//     }
// }

#[generate_trait]
impl ItemImpl of ItemTrait {
    fn get_item(self: @IWorldDispatcher, id: u128) -> Item {
        let ItemModel { id, name: _, stats } = get!((*self), id, ItemModel);
        // let attacks = self.get_attacks(attack_ids);
        Item { id, stats, }
    }
    fn get_items(self: @IWorldDispatcher, ids: Span<u128>) -> Span<Item> {
        let mut items: Array<Item> = ArrayTrait::new();
        let (len, mut n) = (ids.len(), 0_usize);
        while n < len {
            items.append(self.get_item(*ids[n]));
            n += 1;
        };
        items.span()
    }
    fn set_has_attack(self: IWorldDispatcher, item_id: u128, attack: u128) {
        set!(self, HasAttack { id: item_id, attack, has: true });
    }
    fn remove_has_attack(self: IWorldDispatcher, item_id: u128, attack: u128) {
        delete!(self, HasAttack { id: item_id, attack, has: true });
    }
    fn check_has_attack(self: @IWorldDispatcher, item_id: u128, attack: u128) -> bool {
        get!((*self), (item_id, attack), HasAttack).has
    }
}

