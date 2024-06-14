use starknet::{ContractAddress};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

use blob_arena::{
    components::{item::{Item, IdsTrait, ItemIdsImpl, ItemTrait, ItemArrayCopyImpl}},
    models::{WarriorToken, WarriorItemsModel, Attack}, collections::{Collection, CollectionTrait},
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
    items: Array<Item>,
}

#[generate_trait]
impl CollectionAddressImpl of CollectionAddressTrait {
    fn owner_of(self: @ContractAddress, token_id: u256) -> ContractAddress {
        let interface = Collection { contract_address: *self };
        interface.owner_of(token_id)
    }
    fn get_items(self: @ContractAddress, token_id: u256) -> Array<u128> {
        let interface = Collection { contract_address: *self };
        interface.get_items(token_id)
    }
}


#[generate_trait]
impl WarriorImpl of WarriorTrait {
    fn create_warrior(
        self: IWorldDispatcher, collection_address: ContractAddress, token_id: u256
    ) -> u128 {
        let id = get_warrior_id(collection_address, token_id);

        let mut warrior_token = self.get_warrior_token(id);

        warrior_token.collection_address = collection_address;
        warrior_token.token_id = token_id;
        let warrior_items = WarriorItemsModel { id, items: collection_address.get_items(token_id) };

        set!(self, (warrior_token, warrior_items));
        id
    }
    fn get_warrior_token(self: IWorldDispatcher, id: u128) -> WarriorToken {
        get!(self, id, WarriorToken)
    }

    fn get_warrior_items_model(self: IWorldDispatcher, id: u128) -> WarriorItemsModel {
        get!(self, id, WarriorItemsModel)
    }

    fn get_warrior(self: IWorldDispatcher, id: u128) -> Warrior {
        let WarriorItemsModel { id, items: item_ids } = self.get_warrior_items_model(id);
        let WarriorToken { id, collection_address, token_id } = self.get_warrior_token(id);
        Warrior {
            id,
            collection_address,
            token_id,
            owner: collection_address.owner_of(token_id),
            items: self.get_items(item_ids)
        }
    }
    fn get_warriors(self: IWorldDispatcher, ids: Array<u128>) -> Array<Warrior> {
        let mut warriors: Array<Warrior> = ArrayTrait::new();
        let (len, mut n) = (ids.len(), 0_usize);

        while n < len {
            warriors.append(self.get_warrior(*ids.at(n)));
        };
        warriors
    }
    fn get_health(self: @Warrior) -> u8 {
        100
    }
    fn owner_of(self: @Warrior) -> ContractAddress {
        self.collection_address.owner_of(*self.token_id)
    }
    fn assert_owner(self: @Warrior, player: ContractAddress) {
        assert(*self.owner == player, 'Player is not owner');
    }
}
