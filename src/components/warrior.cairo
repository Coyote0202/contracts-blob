use core::array::ArrayTrait;
use starknet::{ContractAddress};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{components::{weapon::{Weapon, WeaponTrait}}, models::{WarriorModel, Attack},};

#[derive(Drop, Print)]
struct Warrior {
    id: u128,
    owner: ContractAddress,
    attacks: Array<Attack>,
    arcade: bool,
}

impl WarriorIntoWarriorModel of Into<Warrior, WarriorModel> {
    fn into(self: Warrior) -> WarriorModel {
        let mut weapon_ids: Array<u128> = ArrayTrait::new();
        let (len, mut n) = (self.weapons.len(), 0_usize);

        while n < len {
            weapon_ids.append(*self.weapons.at(n).id);
        };
        WarriorModel { id: self.id, owner: self.owner, weapons: weapon_ids, arcade: self.arcade }
    }
}

#[generate_trait]
impl WarriorImpl of WarriorTrait {
    fn get_warrior(self: IWorldDispatcher, id: u128) -> Warrior {
        let WarriorModel { id, owner, weapons: weapon_ids, arcade } = get!(self, id, WarriorModel);
        let weapons = self.get_weapons(weapon_ids);
        Warrior { id, owner, weapons, arcade }
    }
    fn get_warriors(self: IWorldDispatcher, ids: Array<u128>) -> Array<Warrior> {
        let mut warriors: Array<Warrior> = ArrayTrait::new();
        let (len, mut n) = (ids.len(), 0_usize);

        while n < len {
            warriors.append(self.get_warrior(*ids.at(n)));
        };
        warriors
    }
}
