use alexandria_data_structures::array_ext::ArrayTraitExt;
use starknet::{ContractAddress};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    models::{ItemModel, HasAttack, AttackModel},
    components::{
        stats::Stats, attack::{Attack, AttackTrait, AttackInput},
        utils::{IdTrait, IdsTrait, TIdsImpl}
    },
    utils::uuid
};

#[derive(Drop, Serde, Copy)]
struct Item {
    id: felt252,
    stats: Stats,
}


// impl ByteArrayCopyImpl of Copy<ByteArray>;
// impl ItemCopyImpl of Copy<Item>;

impl ItemIdImpl of IdTrait<Item> {
    fn id(self: @Item) -> felt252 {
        *self.id
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
//         let mut attack_ids: Array<felt252> = ArrayTrait::new();
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
    fn get_item(self: @IWorldDispatcher, id: felt252) -> Item {
        let ItemModel { id, name: _, stats } = get!((*self), id, ItemModel);
        // let attacks = self.get_attacks(attack_ids);
        Item { id, stats, }
    }
    fn get_items(self: @IWorldDispatcher, ids: Span<felt252>) -> Span<Item> {
        let mut items: Array<Item> = ArrayTrait::new();
        let (len, mut n) = (ids.len(), 0_usize);
        while n < len {
            items.append(self.get_item(*ids[n]));
            n += 1;
        };
        items.span()
    }
    fn create_new_item(self: IWorldDispatcher, name: ByteArray, stats: Stats) -> felt252 {
        let id = uuid(self);
        set!(self, ItemModel { id, name, stats });
        id
    }
    fn set_has_attack(self: IWorldDispatcher, item_id: felt252, attack_id: felt252) {
        set!(self, HasAttack { item_id, attack_id, has: true });
    }
    fn remove_has_attack(self: IWorldDispatcher, item_id: felt252, attack_id: felt252) {
        delete!(self, HasAttack { item_id, attack_id, has: true });
    }
    fn check_has_attack(self: @IWorldDispatcher, item_id: felt252, attack_id: felt252) -> bool {
        get!((*self), (item_id, attack_id), HasAttack).has
    }
    fn create_and_set_new_attack(
        self: IWorldDispatcher, item_id: felt252, attack: AttackInput
    ) -> felt252 {
        let id = self.create_new_attack(attack);
        self.set_has_attack(item_id, id);
        id
    }
    fn create_and_set_new_attacks(
        self: IWorldDispatcher, item_id: felt252, mut attacks: Array<AttackInput>
    ) -> Span<felt252> {
        let mut attack_ids = ArrayTrait::<felt252>::new();
        loop {
            match attacks.pop_front() {
                Option::Some(attack) => {
                    attack_ids.append(self.create_and_set_new_attack(item_id, attack));
                },
                Option::None => { break; }
            }
        };
        attack_ids.span()
    }
}

