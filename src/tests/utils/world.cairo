use starknet::{
    syscalls::deploy_syscall, ContractAddress,
    testing::set_account_contract_address
};
use dojo::{
    test_utils::{deploy_contract, spawn_test_world,},
    world::{IWorldDispatcher, IWorldDispatcherTrait,},
};
fn spawn_world() -> IWorldDispatcher{
    let models = array![
        
    ];
    spawn_test_world(models);
}