use dojo::world::{IWorldDispatcher};
use blob_arena::models::Effect;

#[dojo::interface]
trait IAttackActions {
    fn new_attack(
        ref world: IWorldDispatcher,
        name: ByteArray,
        speed: u8,
        accuracy: u8,
        cooldown: u8,
        hit: Array<Effect>,
        miss: Array<Effect>,
    ) -> u128;
}


#[dojo::contract]
mod attack_actions {
    use starknet::{ContractAddress, get_caller_address};

    use blob_arena::{
        components::{stats::Stats,}, models::{AttackModel, Effect}, utils::uuid,
        world::{WorldTrait, Contract}
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
            hit: Array<Effect>,
            miss: Array<Effect>,
        ) -> u128 {
            let id = uuid(world);
            let attack = AttackModel { id, name, speed, accuracy, cooldown, hit, miss, };
            set!(world, (attack,));
            id
        }
    }
}
