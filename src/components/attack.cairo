use dojo::{world::{IWorldDispatcher, IWorldDispatcherTrait}, model::Model};

use blob_arena::{
    utils::uuid, models::{AttackModel, AvailableAttack},
    components::{utils::{IdTrait, IdsTrait, TIdsImpl}, stats::Stats},
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
    heal: u8,
    buff: Stats,
    debuff: Stats,
}

#[derive(Drop, Serde)]
struct AttackInput {
    name: ByteArray,
    damage: u8,
    speed: u8,
    accuracy: u8,
    critical: u8,
    stun: u8,
    cooldown: u8,
    heal: u8,
    buff: Stats,
    debuff: Stats,
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
        let AttackModel { id, name: _, damage, speed, accuracy, critical, stun, cooldown, heal } =
            self
            .get_attack_model(id);
        Attack { id, damage, speed, accuracy, critical, stun, cooldown, heal }
    }
    fn create_new_attack(self: IWorldDispatcher, attack: AttackInput) -> u128 {
        let AttackInput { name,
        damage,
        speed,
        accuracy,
        critical,
        stun,
        cooldown,
        heal,
        buff,
        debuff } =
            attack;
        let id = uuid(self);
        AttackModel {
            id, name, damage, speed, accuracy, critical, stun, cooldown, heal, buff, debuff
        }
            .set(self);
        id
    }
    // fn get_available_attack(
//     self: IWorldDispatcher, combat_id: u128, combatant: u128, attack: u128,
// ) -> AvailableAttack {
//     get!(self, (combat_id, combatant, attack), AvailableAttack)
// }
// fn set_available_attack(
//     self: IWorldDispatcher, combat_id: u128, combatant: u128, attack: u128, last_used: u32
// ) {
//     set!(self, (AvailableAttack { combat_id, combatant, attack, available: true, last_used
//     }));
// }
}
