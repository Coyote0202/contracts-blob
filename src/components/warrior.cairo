use starknet::{ContractAddress};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    components::{item::{Item, IdsTrait, ItemIdsImpl, ItemTrait}}, models::{WarriorModel, Attack},
};

#[derive(Drop, Print)]
struct Warrior {
    id: u128,
    owner: ContractAddress,
    erc721_address: ContractAddress,
    token_id: u256,
    items: Array<Item>,
    arcade: bool,
}

impl WarriorIntoWarriorModel of Into<Warrior, WarriorModel> {
    fn into(self: Warrior) -> WarriorModel {
        WarriorModel {
            id: self.id, owner: self.owner, items: self.items.ids(), arcade: self.arcade
        }
    }
}

#[generate_trait]
impl WarriorImpl of WarriorTrait {
    fn get_warrior(self: IWorldDispatcher, id: u128) -> Warrior {
        let WarriorModel { id, owner, items: item_ids, arcade } = get!(self, id, WarriorModel);
        Warrior { id, owner, items: self.get_items(item_ids), arcade }
    }
    fn get_warriors(self: IWorldDispatcher, ids: Array<u128>) -> Array<Warrior> {
        let mut warriors: Array<Warrior> = ArrayTrait::new();
        let (len, mut n) = (ids.len(), 0_usize);

        while n < len {
            warriors.append(self.get_warrior(*ids.at(n)));
        };
        warriors
    }
    fn get_health(self: Warrior) -> u8 {
        
    }
}
