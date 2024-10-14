use dojo::{world::{IWorldDispatcher, IWorldDispatcherTrait}, model::Model};

use blob_arena::{
    utils::uuid, models::{AttackModel, AvailableAttack, Effect, AttackStore},
    components::{utils::{IdTrait, IdsTrait, TIdsImpl}, stats::Stats},
};


#[derive(Drop, Serde)]
struct Attack {
    id: u128,
    speed: u8,
    accuracy: u8,
    cooldown: u8,
    hit: Array<Effect>,
    miss: Array<Effect>,
}

#[derive(Drop, Serde)]
struct AttackInput {
    name: ByteArray,
    speed: u8,
    accuracy: u8,
    cooldown: u8,
    hit: Array<Effect>,
    miss: Array<Effect>,
}

#[generate_trait]
impl AttackInputImpl of AttackInputTrait {
    fn to_model(self: @AttackInput, id: u128) -> AttackModel {
        AttackModel {
            id,
            name: self.name.clone(),
            speed: *(self.speed),
            accuracy: *(self.accuracy),
            cooldown: *(self.cooldown),
            hit: self.hit.clone(),
            miss: self.miss.clone(),
        }
    }
}

#[generate_trait]
impl AttackModelImpl of AttackModelTrait {
    fn to_attack(self: @AttackModel) -> Attack {
        Attack {
            id: *(self.id),
            speed: *(self.speed),
            accuracy: *(self.accuracy),
            cooldown: *(self.cooldown),
            hit: self.hit.clone(),
            miss: self.miss.clone(),
        }
    }
}

impl AttackIdImpl of IdTrait<Attack> {
    fn id(self: @Attack) -> u128 {
        *(self.id)
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
        self.get_attack_model(id).to_attack()
    }
    fn create_new_attack(self: IWorldDispatcher, attack: AttackInput) -> u128 {
        let id = uuid(self);
        attack.to_model(id).set(self);
        id
    }
    fn get_attack_speed(self: @IWorldDispatcher, id: u128) -> u8 {
        AttackStore::get_speed(*self, id)
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
