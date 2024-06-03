use starknet::{ContractAddress};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{systems::{weapon::{Weapon, WeaponTrait}}, models::WarriorModel,};


struct Warrior {
    id: u128,
    owner: ContractAddress,
    weapons: Array<Weapon>,
}


impl WarriorIntoWarriorModel of Into<Warrior, WarriorModel> {
    fn into(self: Warrior) -> WarriorModel {
        let mut weapon_ids: Array<u128> = ArrayTrait::new();
        let (len, mut n) = (self.weapons.len(), 0_usize);

        while n < len {
            weapon_ids.append(*self.weapons[n].id);
        };
        WarriorModel { id: self.id, owner: self.owner, weapons: weapon_ids, }
    }
}
#[generate_trait]
impl WarriorImpl of WarriorTrait {
    fn get_warrior(self: IWorldDispatcher, id: u128) -> Warrior {
        let WarriorModel { id, owner, weapons: weapon_ids } = get!(self, id, WeaponModel);
        let mut weapons: Array<Weapon> = ArrayTrait::new();
        Warrior { id, owner, weapons, }
    }
}
