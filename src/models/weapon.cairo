use starknet::ContractAddress;

#[derive(Drop, Serde)]
#[dojo::model]
struct Weapon {
    #[key]
    id: u128,
    name: ByteArray,
    attacks: Array<u128>,
    soulbound: ContractAddress,
}
