use starknet::{ContractAddress, get_caller_address};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    components::{
        stats::Stats, attack::{Attack, AttackIdsImpl, IdsTrait, AttackTrait},
        //  stats::Stats, attack::{Attack, IdsTrait, IdTrait, AttackTrait}, 
        warrior::{Warrior, WarriorTrait}, item::{Item, ItemsTrait}
    },
    models::{CombatantModel, CombatantState},
};


impl U8ArrayCopyImpl of Copy<Array<u8>>;
impl AttackArrayCopyImpl of Copy<Array<Attack>>;

#[derive(Drop, Serde, Copy)]
struct Combatant {
    combat_id: u128,
    warrior_id: u128,
    player: ContractAddress,
    stats: Stats,
    health: u8,
    stun_chances: Array<u8>,
    attacks: Array<Attack>,
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
            // attacks: self.attacks.ids(), //#
            attacks: ArrayTrait::new(),
            stats: self.stats,
        }
    }
}

#[generate_trait]
impl CombatantImpl of CombatantTrait {
    fn create_combatant(self: IWorldDispatcher, warrior: Warrior, combat_id: u128) -> Combatant {
        let combatant = warrior.make_combatant(combat_id);
        let combatant_state: CombatantState = combatant.into();
        let combatant_model: CombatantModel = combatant.into();

        // set!(self, (combatant_model, combatant_state)); //#
        set!(self, (combatant_model,));
        combatant
    }
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
        assert(model.player.is_non_zero(), 'Combatant not found');

        let CombatantModel { combat_id: _, warrior_id: _, player, attacks: attack_ids, stats } =
            model;
        let CombatantState { combat_id: _, warrior_id: _, health, stun_chances } = state;
        let attacks = self.get_attacks(attack_ids);
        Combatant { combat_id, warrior_id, player, attacks, stats, health, stun_chances }
    }

    fn get_player_combatant(
        self: IWorldDispatcher, combat_id: u128, warrior_id: u128
    ) -> Combatant {
        let combatant = self.get_combatant(combat_id, warrior_id);
        let caller = get_caller_address();
        assert(caller == combatant.player, 'Not combatant player');
        combatant
    }

    fn has_attack(self: Combatant, attack_id: u128) -> bool {
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

    fn assert_player(self: Combatant) { // let player_felt252: felt252 = player.into();
    // let caller_felt252: felt252 = get_caller_address().into();
    // let is_player = player_felt252 == caller_felt252;
    // assert(get_caller_address() == self.player, 'Not combatant player'); //#
    }
}
