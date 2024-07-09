use blob_arena::components::stats::Stats;
use dojo::world::{IWorldDispatcher};

#[derive(Drop, Serde)]
struct Attack {
    name: ByteArray,
    damage: u8,
    speed: u8,
    accuracy: u8,
    critical: u8,
    stun: u8,
    cooldown: u8,
}

#[dojo::interface]
trait IItemActions {
    fn new_item(
        ref world: IWorldDispatcher, name: ByteArray, stats: Stats, attacks: Array<u128>
    ) -> u128;
    fn new_item_with_attacks(
        ref world: IWorldDispatcher, name: ByteArray, stats: Stats, attacks: Array<Attack>
    ) -> u128;
}

#[dojo::contract]
mod item_actions {
    use starknet::{ContractAddress, get_caller_address, get_contract_address};

    use blob_arena::{
        components::{stats::Stats, item::ItemTrait}, models::{ItemModel, AttackModel}, utils::uuid,
        world::{WorldTrait, Contract}
    };

    use super::{IItemActions, Attack};


    #[generate_trait]
    impl AttackImpl of AttackTrait {
        fn set_new_attacks(
            self: IWorldDispatcher, item_id: u128, mut attacks: Array<Attack>
        ) -> Array<u128> {
            let mut attack_ids = ArrayTrait::<u128>::new();
            loop {
                match attacks.pop_front() {
                    Option::Some(Attack { name,
                    damage,
                    speed,
                    accuracy,
                    critical,
                    stun,
                    cooldown }) => {
                        let id = uuid(self);
                        attack_ids.append(id);
                        set!(
                            self,
                            AttackModel {
                                id, name, damage, speed, accuracy, critical, stun, cooldown
                            }
                        );
                        self.set_has_attack(item_id, id);
                    },
                    Option::None => { break; }
                }
            };
            attack_ids
        }
    }

    #[abi(embed_v0)]
    impl IItemActionsImpl of IItemActions<ContractState> {
        fn new_item(
            ref world: IWorldDispatcher, name: ByteArray, stats: Stats, attacks: Array<u128>
        ) -> u128 {
            let id = uuid(world);
            set!(world, ItemModel { id, name, stats });
            id
        }
        fn new_item_with_attacks(
            ref world: IWorldDispatcher, name: ByteArray, stats: Stats, attacks: Array<Attack>
        ) -> u128 {
            let attack_ids = world.set_new_attacks(attacks);
            let id = uuid(world);
            set!(world, ItemModel { id, name, stats });
            id
        }
    }
}
