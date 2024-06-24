use starknet::{ContractAddress, get_caller_address, get_block_number};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    components::{
        attack::{Attack, AttackTrait}, combatant::{CombatantInfo, CombatantState, CombatantTrait},
        combat::{Phase,}, utils::{AB, ABT, ABTTrait, ABTImpl}
    },
    models::{PvPCombatantsModel, PvPPlannedAttackModel, CombatState},
};


#[generate_trait]
impl PvPCombatImpl of PvPCombatTrait {
    fn set_pvp_combatants<T, +Into<T, (u128, u128)>>(
        self: IWorldDispatcher, id: u128, combatants: T
    ) {
        set!(self, PvPCombatantsModel { id, combatants: combatants.into() });
    }

    fn get_pvp_combatants(self: @IWorldDispatcher, id: u128) -> ABT<u128> {
        ABTTrait::new_from_tuple(get!((*self), id, PvPCombatantsModel).combatants)
    }

    fn get_pvp_planned_attack(self: @IWorldDispatcher, id: u128) -> u128 {
        get!((*self), id, PvPPlannedAttackModel).attack
    }
    fn set_pvp_planned_attack(self: IWorldDispatcher, id: u128, attack: u128) {
        set!(self, PvPPlannedAttackModel { id: id, attack },);
    }
    fn check_pvp_planned_attack_set(self: @IWorldDispatcher, id: u128) -> bool {
        self.get_pvp_planned_attack(id).is_non_zero()
    }
    fn set_clear_pvp_planned_attack(self: IWorldDispatcher, id: u128, attack: u128) {
        assert(self.check_pvp_planned_attack_set(id), 'Attack already set');
        self.set_pvp_planned_attack(id, attack);
    }
    fn get_pvp_attacks(self: @IWorldDispatcher, combatants: ABT<u128>) -> ABT<Attack> {
        ABTTrait::new(
            self.get_attack(self.get_pvp_planned_attack(combatants.a)),
            self.get_attack(self.get_pvp_planned_attack(combatants.b))
        )
    }
}


// #[generate_trait]
// impl ABCombatantImpl of ABCombatantTrait {
//     fn get_combatant_ab(self: @ABT<CombatantInfo>, warrior_id: u128) -> AB {
//         if warrior_id == *self.a.warrior_id {
//             AB::A
//         } else if warrior_id == *self.b.warrior_id {
//             AB::B
//         } else {
//             panic!("Invalid warrior_id")
//         }
//     }
//     fn get_combatant(self: @ABT<CombatantInfo>, warrior_id: u128) -> CombatantInfo {
//         if warrior_id == *self.a.warrior_id {
//             *self.a
//         } else if warrior_id == *self.b.warrior_id {
//             *self.b
//         } else {
//             panic!("Invalid warrior_id")
//         }
//     }
// }

#[generate_trait]
impl ABStateImpl of ABStateTrait {
    fn both_true(self: ABT<bool>) -> bool {
        self.a && self.b
    }
    fn reset(ref self: ABT<bool>) {
        self.a = false;
        self.b = false;
    }
}
// #[generate_trait]
// impl ABCombatantStateImpl of ABCombatantStateTrait {
//     fn get_winner(self: ABT<CombatantState>) -> PvPWinner {
//         if self.b.health.is_zero() && self.a.health.is_non_zero() {
//             PvPWinner::A
//         } else if self.a.health.is_zero() && self.b.health.is_non_zero() {
//             PvPWinner::B
//         } else {
//             PvPWinner::None
//         }
//     }
//     fn is_running(self: ABT<CombatantState>) -> bool {
//         self.a.health.is_non_zero() && self.b.health.is_non_zero()
//     }
// }


