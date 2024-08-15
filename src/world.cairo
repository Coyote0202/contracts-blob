use starknet::{get_caller_address, ContractAddress};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};


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
    fn assert_caller_is_writer<T, +Into<T, felt252>, +Drop<T>>(
        self: @IWorldDispatcher, contract: T
    ) -> ContractAddress {
        let caller = get_caller_address();
        assert((*self).is_writer(contract.into(), caller), 'Not Writer');
        caller
    }
    fn assert_caller_is_owner(
        self: @IWorldDispatcher, contract: ContractAddress
    ) -> ContractAddress {
        let caller = get_caller_address();
        assert((*self).is_owner(caller, contract.into()), 'Not Admin');
        caller
    }
}
