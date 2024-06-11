use core::array::ArrayTrait;
use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    components::{
        stats::Stats, weapon::{Weapon, WeaponTrait},
        // attack::{Attack, AttackIdsImpl, IdsTrait, AttackArrayCopyImpl, AttackTrait},
        attack::{Attack, AttackIdsImpl, IdsTrait, AttackTrait}, warrior::{Warrior, WarriorTrait},
        item::{Item, ItemsTrait}
    },
    models::{WarriorModel, CombatantModel, CombatantState},
};


impl U8ArrayCopyImpl of Copy<Array<u8>>;
impl AttackArrayCopyImpl of Copy<Array<Attack>>;

#[derive(Drop, Serde, Copy)]
struct Combatant {
    combat_id: u128,
    warrior_id: u128,
    player: ContractAddress,
    attacks: Array<Attack>,
    stats: Stats,
    health: u8,
    stun_chances: Array<u8>,
}

impl CombatantIntoCombatantState of Into<Combatant, CombatantState> {
    fn into(self: Combatant) -> CombatantState {
        CombatantState {
            combat_id: self.combat_id,
            warrior_id: self.warrior_id,
            health: self.health,
            stun_chances: self.stun_chances,
        }
    }
}


impl CombatantIntoCombatantModel of Into<Combatant, CombatantModel> {
    fn into(self: Combatant) -> CombatantModel {
        CombatantModel {
            combat_id: self.combat_id,
            warrior_id: self.warrior_id,
            player: self.player,
            attacks: self.attacks.ids(),
            stats: self.stats,
        }
    }
}

#[generate_trait]
impl CombatantImpl of CombatantTrait {
    fn make_combatant(self: Warrior, combat_id: u128) -> Combatant {
        let items = self.items.span();
        Combatant {
            combat_id,
            warrior_id: self.id,
            player: self.owner,
            attacks: items.get_attacks(),
            stats: items.get_stats(),
            health: self.get_health(),
            stun_chances: ArrayTrait::<u8>::new(),
        }
    }

    fn get_combatant(self: IWorldDispatcher, combat_id: u128, warrior_id: u128) -> Combatant {
        let (model, state): (CombatantModel, CombatantState) = get!(
            self, (combat_id, warrior_id), (CombatantModel, CombatantState)
        );
        let CombatantModel { combat_id: _, warrior_id: _, player, attacks: attack_ids, stats } =
            model;
        let CombatantState { combat_id: _, warrior_id: _, health, stun_chances } = state;
        let attacks = self.get_attacks(attack_ids);
        Combatant { combat_id, warrior_id, player, attacks, stats, health, stun_chances }
    }

    fn has_attack(self: @Combatant, attack_id: u128) -> bool {
        let (len, mut n) = (self.attacks.len(), 0_usize);
        let mut has_attack = false;
        while n < len {
            if *self.attacks.at(n).id == attack_id {
                has_attack = true;
                break;
            }
            n += 1;
        };
        has_attack
    }
}
