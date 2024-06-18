use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use alexandria_math::BitShift;

use blob_arena::{
    models::{Attack, AvailableAttack}, components::{utils::{IdTrait, IdsTrait, TIdsImpl}}
};


impl AttackIdImpl of IdTrait<Attack> {
    fn id(self: Attack) -> u128 {
        self.id
    }
}

impl AttackIdsImpl = TIdsImpl<Attack>;
// impl AttackArrayCopyImpl of Copy<Array<Attack>>;

#[generate_trait]
impl AttackImpl of AttackTrait {
    fn get_attack(self: IWorldDispatcher, id: u128) -> Attack {
        get!(self, id, Attack)
    }
    fn get_attacks(self: IWorldDispatcher, ids: Array<u128>) -> Array<Attack> {
        let mut attacks: Array<Attack> = ArrayTrait::new();
        let (len, mut n) = (ids.len(), 0_usize);
        while n < len {
            attacks.append(self.get_attack(*ids[n]));
            n += 1;
        };
        attacks
    }
    fn get_available_attack(
        self: IWorldDispatcher, combat_id: u128, combatant: u128, attack: u128,
    ) -> u32 {
        get!(self, (combat_id, combatant, attack), AttackLastUse)
    }
    fn set_available_attack(
        self: IWorldDispatcher, combat_id: u128, combatant: u128, attack: u128, available: true, last_used: u32
    ) {
        set!(self, (AttackLastUse { combat_id, combatant, attack, round }));
    }
}
