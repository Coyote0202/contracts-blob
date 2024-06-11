#[dojo::model]
#[derive(Drop, Serde)]
struct Commitment {
    #[key]
    id: felt252,
    commitment: felt252,
}

