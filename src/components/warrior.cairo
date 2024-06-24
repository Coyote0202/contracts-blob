use starknet::{ContractAddress};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use blob_arena::{
    components::{attack::Attack, item::{Item, IdsTrait, ItemIdsImpl, ItemTrait}},
    models::{WarriorToken, WarriorItemsModel}, collections::{CollectionTrait},
    utils::{value_to_uuid, hash_value}
};


fn get_warrior_id(collection_address: ContractAddress, token_id: u256) -> u128 {
    value_to_uuid((collection_address, token_id))
}

#[derive(Drop, Print, Copy)]
struct Warrior {
    id: u128,
    collection_address: ContractAddress,
    token_id: u256,
    owner: ContractAddress,
    items: Span<Item>,
}


#[generate_trait]
impl WarriorImpl of WarriorTrait {
    fn get_warrior(
        self: @IWorldDispatcher, collection_address: ContractAddress, token_id: u256
    ) -> Warrior {
        Warrior {
            id: get_warrior_id(collection_address, token_id),
            collection_address,
            token_id,
            owner: collection_address.owner_of(token_id),
            items: self.get_items(collection_address.get_items(token_id))
        }
    }

    // fn get_warriors(self: IWorldDispatcher, ids: Array<u128>) -> Array<Warrior> {
    //     let mut warriors: Array<Warrior> = ArrayTrait::new();
    //     let (len, mut n) = (ids.len(), 0_usize);

    //     while n < len {
    //         warriors.append(self.get_warrior(*ids.at(n)));
    //     };
    //     warriors
    // }
    fn assert_owner(self: @Warrior, player: ContractAddress) {
        assert(*self.owner == player, 'Player is not owner');
    }
}
