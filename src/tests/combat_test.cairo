#[cfg(test)]
mod test {
    use blob_arena::{
        components::{
            blobert::{Traits, Background, Armour, Mask, Jewelry, Weapon, calculate_stats},
            stats::Stats, combat::{Move, MatchResult, Outcome, AB}
        },
        systems::combat::{get_outcome, calculate_damage}
    };
    #[test]
    #[available_gas(3000000000)]
    fn test_combat() {
        let traits_a = Traits {
            armour: Armour::LordsArmor,
            background: Background::Holo,
            jewelry: Jewelry::Amulet,
            mask: Mask::Bane,
            weapon: Weapon::Katana,
        };
        let traits_b = Traits {
            armour: Armour::Underpants,
            background: Background::Green,
            jewelry: Jewelry::Necklace,
            mask: Mask::Milady,
            weapon: Weapon::Balloons,
        };
        println!("A Traits: {}", traits_a);
        println!("B Traits: {}", traits_b);
        let stats_a = calculate_stats(traits_a);
        let stats_b = calculate_stats(traits_b);
        println!("A Stats: {}", stats_a);
        println!("B Stats: {}", stats_b);
        // println!(
        //     "a Stats: attack: {} defense: {} speed: {} strength: {}",
        //     stats_a.attack,
        //     stats_a.defense,
        //     stats_a.speed,
        //     stats_a.strength
        // );
        // println!(
        //     "b Stats: attack: {} defense: {} speed: {} strength: {}",
        //     stats_b.attack,
        //     stats_b.defense,
        //     stats_b.speed,
        //     stats_b.strength
        // );
        // let stats_a = Stats { attack: 10, defense: 20, speed: 20, strength: 20, };
        // let stats_b = Stats { attack: 0, defense: 0, speed: 0, strength: 0, };
        let mut n: u8 = 0;
        loop {
            let move_a: Move = n.into();
            let mut m: u8 = 0;
            loop {
                let move_b: Move = m.into();
                let outcome = get_outcome(move_a, move_b);
                let (damage_a, damage_b) = calculate_damage(stats_a, stats_b, outcome);

                println!(
                    "a: {} \t{}\tb: {} \t{}\tresult: {} ",
                    move_a,
                    damage_a,
                    move_b,
                    damage_b,
                    outcome
                );

                if m == 2 {
                    break;
                }
                m += 1;
            };
            if n == 2 {
                break;
            }
            n += 1;
        };
    }
}
