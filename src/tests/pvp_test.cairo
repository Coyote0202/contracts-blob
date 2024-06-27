#[cfg(test)]
mod test {
    use blob_arena::{components::{}, systems::combat::{damage_calculation}};


    #[test]
    #[available_gas(3000000000)]
    fn test_combat() {
        let mut attack = 0_u8;
        let mut damage = 0_u8;
        while attack <= 100 {
            while damage < 100 {
                let calc_damage = damage_calculation(attack, damage, false);
                println!("Attack: {}, Damage: {}, Calc Damage: {}", attack, damage, calc_damage);
                damage += 20;
            };

            attack += 20;
        };
    }
}
