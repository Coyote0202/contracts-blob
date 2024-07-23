use blob_arena::components::stats::Stats;


#[dojo::model]
#[derive(Drop, Serde)]
struct Item {
    #[key]
    id: u128,
    name: ByteArray,
    stats: Stats,
}

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct HasAttack {
    #[key]
    item_id: u128,
    #[key]
    attack_id: u128,
    has: bool,
}
