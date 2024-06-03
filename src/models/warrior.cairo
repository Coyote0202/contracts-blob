use starknet::ContractAddress;

#[dojo::model]
#[derive(Drop, Print, Serde)]
struct Warrior {
    #[key]
    id: u128,
    owner: ContractAddress,
    weapons: Array<u128>,
    arcade: bool,
}

