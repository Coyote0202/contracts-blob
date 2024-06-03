use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::components::{attack::Attack};


#[generate_trait]
impl AttackImpl of AttackTrait {
    fn get_attack(self: IWorldDispatcher, id: u128) -> Attack {
        get!(self, id, Attack)
    }
    fn get_attacks(self: IWorldDispatcher, ids: Array<u128>) -> Array<Attack> {
        let mut attacks: Array<Attack> = ArrayTrait::new();
        let mut n: usize = 0;
        let len = ids.len();
        while n < len {
            attacks.append(self.get_attack(*ids[n]));
            n += 1;
        };
        attacks
    }
}
