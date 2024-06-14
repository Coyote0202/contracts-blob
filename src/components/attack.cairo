use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use alexandria_math::BitShift;

use blob_arena::{
    models::{Attack, AttackLastUse}, components::{utils::{IdTrait, IdsTrait, TIdsImpl}}
};


impl AttackIdImpl of IdTrait<Attack> {
    fn id(self: Attack) -> u128 {
        self.id
    }
}

impl AttackIdsImpl = TIdsImpl<Attack>;
impl AttackArrayCopyImpl of Copy<Array<Attack>>;

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


    fn did_hit(self: Attack, seed: u256) -> bool {
        (BitShift::shr(seed, 8) % 255).try_into().unwrap() < self.accuracy
    }

    fn did_critical(self: Attack, seed: u256) -> bool {
        (BitShift::shr(seed, 16) % 255).try_into().unwrap() < self.critical
    }
    fn get_attack_last_use(
        self: IWorldDispatcher, combat_id: u128, combatant: u128, attack: u128,
    ) -> u32 {
        get!(self, (combat_id, combatant, attack), AttackLastUse).round
    }
    fn set_attack_last_used(
        self: IWorldDispatcher, combat_id: u128, combatant: u128, attack: u128, round: u32
    ) {
        set!(self, (AttackLastUse { combat_id, combatant, attack, round }));
    }
}
