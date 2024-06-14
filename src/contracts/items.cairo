use blob_arena::components::stats::Stats;

#[starknet::interface]
trait IItemsActions<TContractState> {
    fn new(self: @TContractState, name: ByteArray, stats: Stats, attacks: Array<u128>);
}
