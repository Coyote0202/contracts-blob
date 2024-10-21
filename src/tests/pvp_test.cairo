#[cfg(test)]
mod test {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use blob_arena::{
        components::{combatant::{CombatantState, CombatantStats}, attack::{Attack}},
        systems::combat::{damage_calculation, apply_luck_modifier}
    };


    #[test]
    #[available_gas(3000000000)]
    fn test_hit() {
        // let mut attack = AttackModel{
        //     id: 12,
        //     name: "Test Attack",
        //     speed: 10,
        //     damage: 10,
        //     accuracy: 90,
        //     critical: 10,
        //     stun: 10,
        //     cooldown: 0,
        // };
        // let stats = CombatantStats {
        //     id: 12,
        //     attack: 50,
        //     vitality: 50,
        //     speed: 50,
        //     luck: 50,
        // }
        let mut accuracy = 0_u8;
        while accuracy <= 100 {
            let mut seed = felt252_to_u128(hash_value('peanut butter'));
            let mut n = 0;
            while n.into() < 10_u256 {
                let (_seed, did_hit) = did_hit(accuracy, seed);
                seed = _seed;
                println!("Accuracy: {}, Seed: {}, Did Hit: {}", accuracy, seed, did_hit);
                n += 1;
            };
            accuracy += 10;
            println!(" --- ");
        };
    }


    #[test]
    #[available_gas(3000000000)]
    fn test_heal_move() {
        let mut combatant_a_stats = CombatantStats {
            id: 1, attack: 10, vitality: 10, speed: 10, luck: 10,
        };

        let mut combatant_a_state = CombatantState { id: 1, health: 100, stun_chance: 0, };

        let heal_move = Attack {
            id: 1, damage: 0, speed: 150, accuracy: 0, critical: 0, stun: 0, cooldown: 0, heal: 10,
        };

        let mut world_dispatcher = WorldDispatcher::default();
        world_dispatcher
            .run_attack(
                combatant_a_stats,
                combatant_a_state,
                combatant_a_state,
                heal_move,
                1, // Round number
                HashState::default()
            );
    }
}
