use starknet::{ContractAddress};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    models::WeaponModel, components::{attack::{Attack}, traits::weapon::{Weapon as WeaponM,},},
    systems::{attack::AttackTrait}
};

#[derive(Copy, Drop, Print, Introspect)]
struct Weapon {
    id: u128,
    name: ByteArray,
    attacks: Array<Attack>,
    soulbound: ContractAddress,
}


impl WeaponIntoWeaponModel of Into<Weapon, WeaponModel> {
    fn into(self: Weapon) -> WeaponModel {
        let mut attack_ids: Array<u128> = ArrayTrait::new();
        let mut n: usize = 0;
        while (n < self.attacks.len()) {
            attack_ids.append(self.attacks[n].id);
            n += 1;
        };
        WeaponModel { id: self.id, name: self.name, attacks: attack_ids, soulbound: self.soulbound }
    }
}

#[generate_trait]
impl WeaponImpl of WeaponTrait {
    fn get_weapon(self: IWorldDispatcher, id: u128) -> Weapon {
        let WeaponModel { id, name, attacks: attack_ids, soulbound } = get!(self, id, WeaponModel);
        let attacks = self.get_attacks(attack_ids);
        Weapon { id, name, attacks, soulbound }
    }
    fn get_weapons(self: IWorldDispatcher, ids: Array<u128>) -> Array<Weapon> {
        let mut weapons: Array<Weapon> = ArrayTrait::new();
        let mut n: usize = 0;
        let len = ids.len();
        while n < len {
            weapons.append(self.get_weapon(*ids[n]));
            n += 1;
        };
        weapons
    }
}
