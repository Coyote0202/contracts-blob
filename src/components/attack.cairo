use dojo::{world::{IWorldDispatcher, IWorldDispatcherTrait}, model::Model};

use blob_arena::{
    core::Signed, utils::uuid,
    models::{AttackModel, AvailableAttack, Effect, Affect, AttackStore, Target, Damage, Stat},
    components::{utils::{IdTrait, IdsTrait, TIdsImpl}, stats::{Stats, TStats, StatTypes},},
};


#[derive(Drop, Serde)]
struct Attack {
    id: felt252,
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
    hit: Array<EffectInput>,
    miss: Array<EffectInput>,
}

#[derive(Drop, Serde, Copy, PartialEq, Introspect)]
struct StatInput {
    stat: StatTypes,
    amount: Signed<u8>,
}
#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
struct EffectInput {
    target: Target,
    affect: AffectInput,
}

#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum AffectInput {
    Stats: TStats<Signed<u8>>,
    Stat: StatInput,
    Damage: Damage,
    Stun: u8,
    Health: Signed<u8>,
}


impl InputIntoAffect of Into<AffectInput, Affect> {
    fn into(self: AffectInput) -> Affect {
        match self {
            AffectInput::Stats(stats) => Affect::Stats(stats.into()),
            AffectInput::Stat(stat) => Affect::Stat(
                Stat { stat: stat.stat, amount: stat.amount.into() }
            ),
            AffectInput::Damage(damage) => Affect::Damage(damage),
            AffectInput::Stun(stun) => Affect::Stun(stun),
            AffectInput::Health(health) => Affect::Health(health.into()),
        }
    }
}

impl InputIntoEffect of Into<EffectInput, Effect> {
    fn into(self: EffectInput) -> Effect {
        Effect { target: self.target, affect: self.affect.into() }
    }
}

impl InputIntoEffectArray of Into<Array<EffectInput>, Array<Effect>> {
    fn into(mut self: Array<EffectInput>) -> Array<Effect> {
        let mut effects = array![];
        loop {
            match self.pop_front() {
                Option::Some(effect) => { effects.append(effect.into()); },
                Option::None => { break; },
            };
        };
        effects
    }
}

#[generate_trait]
impl AttackInputImpl of AttackInputTrait {
    fn to_model(self: @AttackInput, id: felt252) -> AttackModel {
        AttackModel {
            id,
            name: self.name.clone(),
            speed: *(self.speed),
            accuracy: *(self.accuracy),
            cooldown: *(self.cooldown),
            hit: self.hit.clone().into(),
            miss: self.miss.clone().into(),
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
    fn id(self: @Attack) -> felt252 {
        *(self.id)
    }
}

impl AttackIdsImpl = TIdsImpl<Attack>;
// impl AttackArrayCopyImpl of Copy<Array<Attack>>;

#[generate_trait]
impl AttackImpl of AttackTrait {
    fn get_attack_model(self: @IWorldDispatcher, id: felt252) -> AttackModel {
        get!((*self), id, AttackModel)
    }
    fn get_attack(self: @IWorldDispatcher, id: felt252) -> Attack {
        self.get_attack_model(id).to_attack()
    }
    fn create_new_attack(self: IWorldDispatcher, attack: AttackInput) -> felt252 {
        let id = uuid(self);
        attack.to_model(id).set(self);
        id
    }
    fn get_attack_speed(self: @IWorldDispatcher, id: felt252) -> u8 {
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
