use dojo::world::{IWorldDispatcher};


#[dojo::interface]
trait IAttackActions {
    fn set_attack(
        ref world: IWorldDispatcher,
        name: ByteArray,
        damage: u8,
        speed: u8,
        accuracy: u8,
        critical: u8,
        stun: u8,
        cooldown: u8,
    ) -> u128;
}


#[dojo::contract]
mod attack_actions {
    use starknet::{ContractAddress, get_caller_address};

    use blob_arena::{
        components::{stats::Stats, world::{WorldTrait, Contract}}, models::AttackModel, utils::uuid
    };

    use super::IAttackActions;

    #[abi(embed_v0)]
    impl IAttackActionsImpl of IAttackActions<ContractState> {
        fn set_attack(
            ref world: IWorldDispatcher,
            name: ByteArray,
            damage: u8,
            speed: u8,
            accuracy: u8,
            critical: u8,
            stun: u8,
            cooldown: u8,
        ) -> u128 {
            let id = uuid(world);
            let attack = AttackModel {
                id, name, damage, speed, accuracy, critical, stun, cooldown,
            };
            world.assert_caller_is_writer(Contract::Attack);
            set!(world, (attack,));
            id
        }
    }
}
