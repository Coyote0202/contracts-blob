#[cfg(test)]
mod test {
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use blob_arena::{
        components::{
            combatant::{CombatantState, CombatantStats},
            attack::{Attack}
        },
        systems::combat::{damage_calculation, apply_strength_modifier}};


    #[test]
    #[available_gas(3000000000)]
    fn test_damage() {
        let mut damage = 0_u8;
        while damage <= 100 {
            let mut attack = 0_u8;
            while attack <= 100 {
                let calc_damage = damage_calculation(attack, damage, false);
                println!("Damage: {}, Attack: {}, Calc Damage: {}", damage, attack, calc_damage);
                attack += 20;
            };
            damage += 20;
        };
    }
    #[test]
    #[available_gas(3000000000)]
    fn test_strength_modifier() {
        let mut strength = 0_u8;
        while strength <= 100 {
            let mut value = 0_u8;
            while value <= 100 {
                let calc_damage: u8 = apply_strength_modifier(value, strength);
                println!("Value: {},\tStrength: {},\tCalc Value: {}", value, strength, calc_damage);
                value += 20;
            };
            strength += 20;
        };
    }

    
    #[test]
    #[available_gas(3000000000)]
    fn test_heal_move() {
        let mut combatant_a_stats = CombatantStats {
            id: 1,
            attack: 10,
            defense: 10,
            speed: 10,
            strength: 10,
        };

        let mut combatant_a_state = CombatantState {
            id: 1,
            health: 100,
            stun_chance: 0,
        };

        let heal_move = Attack {
            id: 1,
            damage: 0,
            speed: 150,
            accuracy: 0,
            critical: 0,
            stun: 0,
            cooldown: 0,
            heal: 10,
        };

        let mut world_dispatcher = WorldDispatcher::default();
        world_dispatcher.run_attack(
            combatant_a_stats,
            combatant_a_state,
            combatant_a_state,
            heal_move,
            1, // Round number
            HashState::default()
        );
    }
}