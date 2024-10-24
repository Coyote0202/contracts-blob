use blob_arena::components::stats::Stats;


#[dojo::model]
#[derive(Drop, Serde)]
struct Item {
    #[key]
    id: felt252,
    name: ByteArray,
    stats: Stats,
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct HasAttack {
    #[key]
    item_id: felt252,
    #[key]
    attack_id: felt252,
    has: bool,
}
