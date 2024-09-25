#[cfg(test)]
mod test {
    use blob_arena::{
        systems::combat::{damage_calculation, apply_strength_modifier, did_hit},
        models::{AttackModel, CombatantStats}, utils::{hash_value, felt252_to_u128}
    };
    use core::integer::u128_safe_divmod;
    const NZ_255: NonZero<u128> = 255;


    // #[test]
    // #[available_gas(3000000000)]
    // fn test_damage() {
    //     let mut damage = 0_u8;
    //     while damage <= 100 {
    //         let mut attack = 0_u8;
    //         while attack <= 100 {
    //             let calc_damage = damage_calculation(attack, damage, false);
    //             println!("Damage: {}, Attack: {}, Calc Damage: {}", damage, attack, calc_damage);
    //             attack += 20;
    //         };
    //         damage += 20;
    //     };
    // }
    // #[test]
    // #[available_gas(3000000000)]
    // fn test_strength_modifier() {
    //     let mut strength = 0_u8;
    //     while strength <= 100 {
    //         let mut value = 0_u8;
    //         while value <= 100 {
    //             let calc_damage: u8 = apply_strength_modifier(value, strength);
    //             println!("Value: {},\tStrength: {},\tCalc Value: {}", value, strength,
    //             calc_damage);
    //             value += 20;
    //         };
    //         strength += 20;
    //     };
    // }

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
        //     defense: 50,
        //     speed: 50,
        //     strength: 50,
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
}
