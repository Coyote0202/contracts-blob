use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use alexandria_math::BitShift;

use blob_arena::{
    models::{AttackModel, AvailableAttack}, components::{utils::{IdTrait, IdsTrait, TIdsImpl}}
};

#[derive(Drop, Serde, Copy)]
struct Attack {
    id: u128,
    damage: u8,
    speed: u8,
    accuracy: u8,
    critical: u8,
    stun: u8,
    cooldown: u8,
}

impl AttackIdImpl of IdTrait<Attack> {
    fn id(self: Attack) -> u128 {
        self.id
    }
}

impl AttackIdsImpl = TIdsImpl<Attack>;
// impl AttackArrayCopyImpl of Copy<Array<Attack>>;

#[generate_trait]
impl AttackImpl of AttackTrait {
    fn get_attack_model(self: @IWorldDispatcher, id: u128) -> AttackModel {
        get!((*self), id, AttackModel)
    }
    fn get_attack(self: @IWorldDispatcher, id: u128) -> Attack {
        let AttackModel { id, name: _, damage, speed, accuracy, critical, stun, cooldown } = self
            .get_attack_model(id);
        Attack { id, damage, speed, accuracy, critical, stun, cooldown, }
    }
    fn get_attacks(self: @IWorldDispatcher, ids: Span<u128>) -> Span<Attack> {
        let mut attacks: Array<Attack> = ArrayTrait::new();
        let (len, mut n) = (ids.len(), 0_usize);
        while n < len {
            attacks.append(self.get_attack(*ids[n]));
            n += 1;
        };
        attacks.span()
    }
// fn get_available_attack(
//     self: IWorldDispatcher, combat_id: u128, combatant: u128, attack: u128,
// ) -> AvailableAttack {
//     get!(self, (combat_id, combatant, attack), AvailableAttack)
// }
// fn set_available_attack(
//     self: IWorldDispatcher, combat_id: u128, combatant: u128, attack: u128, last_used: u32
// ) {
//     set!(self, (AvailableAttack { combat_id, combatant, attack, available: true, last_used }));
// }
}
