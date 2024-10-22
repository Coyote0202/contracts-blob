use dojo::world::{IWorldDispatcher};
use blob_arena::{components::attack::EffectInput};

#[dojo::interface]
trait IAttackActions {
    fn new_attack(
        ref world: IWorldDispatcher,
        name: ByteArray,
        speed: u8,
        accuracy: u8,
        cooldown: u8,
        hit: Array<EffectInput>,
        miss: Array<EffectInput>,
    ) -> u128;
}


#[dojo::contract]
mod attack_actions {
    use starknet::{ContractAddress, get_caller_address};

    use blob_arena::{
        components::{stats::Stats, attack::{EffectInput, InputIntoEffectArray}},
        models::{AttackModel, Effect}, utils::uuid, world::{WorldTrait, Contract}
    };

    use super::IAttackActions;

    #[abi(embed_v0)]
    impl IAttackActionsImpl of IAttackActions<ContractState> {
        fn new_attack(
            ref world: IWorldDispatcher,
            name: ByteArray,
            speed: u8,
            accuracy: u8,
            cooldown: u8,
            hit: Array<EffectInput>,
            miss: Array<EffectInput>,
        ) -> u128 {
            let id = uuid(world);
            let attack = AttackModel {
                id, name, speed, accuracy, cooldown, hit: hit.into(), miss: miss.into(),
            };
            set!(world, (attack,));
            id
        }
    }
}
