#[dojo::model]
#[derive(Copy, Drop, Serde, PartialEq)]
struct Stake {
    #[key]
    combat_id: u128,
    amount: u256,
    blobert: u256,
}

