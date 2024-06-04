use core::array::ArrayTrait;
use blob_arena::components::attack::AttackTrait;
use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    components::{
        stats::Stats, weapon::{Weapon, WeaponTrait}, attack::{Attack, AttackIdsImpl, IdsTrait},
        warrior::{Warrior, WarriorTrait}, item::{Item, ItemsTrait}
    },
    models::{WarriorModel, CombatantModel, CombatantState},
};


#[derive(Drop, Serde)]
struct Combatant {
    combat_id: u128,
    warrior_id: u128,
    player: ContractAddress,
    attacks: Array<Attack>,
    stats: Stats,
    health: u8,
    stunned: bool,
    stun_chance: u8,
}

impl CombatantIntoCombatantState of Into<Combatant, CombatantState> {
    fn into(self: Combatant) -> CombatantState {
        CombatantState {
            combat_id: self.combat_id,
            warrior_id: self.warrior_id,
            health: self.health,
            stunned: self.stunned,
            stun_chance: self.stun_chance
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
            stunned: false,
            stun_chance: 0,
        }
    }

    fn get_combatant(self: IWorldDispatcher, combat_id: u128, warrior_id: u128) -> Combatant {
        let (model, state): (CombatantModel, CombatantState) = get!(
            self, (combat_id, warrior_id), (CombatantModel, CombatantState)
        );
        let CombatantModel { combat_id: _, warrior_id: _, player, attacks: attack_ids, stats } =
            model;
        let CombatantState { combat_id: _, warrior_id: _, health, stunned, stun_chance } = state;
        let attacks = self.get_attacks(attack_ids);
        Combatant { combat_id, warrior_id, player, attacks, stats, health, stunned, stun_chance }
    }
}
