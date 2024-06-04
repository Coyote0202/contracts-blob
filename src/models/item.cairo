use blob_arena::components::stats::Stats;

#[dojo::model]
#[derive(Drop, Serde)]
struct Item {
    #[key]
    id: u128,
    name: ByteArray,
    stats: Stats,
    attacks: Array<u128>,
}
