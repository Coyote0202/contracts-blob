use starknet::ContractAddress;

#[dojo::model]
#[derive(Drop, Print, Serde)]
struct WarriorToken {
    #[key]
    id: u128,
    collection_address: ContractAddress,
    token_id: u256,
}

#[dojo::model]
#[derive(Drop, Print, Serde)]
struct WarriorItems {
    #[key]
    id: u128,
    items: Array<u128>,
}

