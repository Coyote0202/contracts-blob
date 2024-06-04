use starknet::ContractAddress;

#[dojo::model]
#[derive(Drop, Print, Serde)]
struct Warrior {
    #[key]
    id: u128,
    owner: ContractAddress,
    items: Array<u128>,
    arcade: bool,
}

