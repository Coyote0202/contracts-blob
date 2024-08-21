use starknet::{get_caller_address, ContractAddress, get_contract_address};
use dojo::{
    world::{IWorldDispatcher, IWorldDispatcherTrait},
    contract::{IContractDispatcherTrait, IContractDispatcher}
};


#[derive(Copy, Drop, Serde, PartialEq, Introspect)]
enum Contract {
    World,
    Attack,
    Item,
    PvP,
    PvPAdmin,
}

impl ContractIntoFelt252 of Into<Contract, felt252> {
    fn into(self: Contract) -> felt252 {
        match self {
            Contract::World => 0,
            Contract::Attack => 'Attack',
            Contract::Item => 'Item',
            Contract::PvP => 'PvP',
            Contract::PvPAdmin => 'PvPAdmin',
        }
    }
}


#[generate_trait]
impl WorldImpl of WorldTrait {
    fn assert_caller_is_owner(self: @IWorldDispatcher) -> ContractAddress {
        let dispatcher = IContractDispatcher { contract_address: get_contract_address(), };
        let selector = dispatcher.selector();
        let caller = get_caller_address();
        assert((*self).is_owner(selector, caller), 'Not Admin');
        caller
    }
}
