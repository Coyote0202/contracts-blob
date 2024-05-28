#[dojo::model]
#[derive(Copy, Drop, Print, Serde, PartialEq)]
struct Stake {
    #[key]
    combat_id: u128,
    amount: u256,
    blobert: bool,
}
