use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};

type World = IWorldDispatcher;
// trait WorldTrait<T> {
//     fn get_world(self: @T) -> World;
// }

// #[dojo::contract]
// mod world_actions {
//     use super::{World, WorldTrait};
//     impl WorldImpl of WorldTrait<ContractState> {
//         fn get_world(self: @ContractState) -> World {
//             self.world_dispatcher.read()
//         }
//     }
// }


