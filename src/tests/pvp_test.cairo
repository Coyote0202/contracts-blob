#[cfg(test)]
mod test {
    use blob_arena::{systems::combat::{damage_calculation, apply_strength_modifier}};


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
}
