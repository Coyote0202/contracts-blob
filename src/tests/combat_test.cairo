use blob_arena::{
    models::{
        combatant:: {
            CombatantState,
            CombatantInfo,
            CombatantStats,
        },
        attack::{
            Attack,
            Affect,
            Effect, 
            Damage, 
            Target, 
        },
    },
    components::{
        stats::{
            TStats,
            StatTypes,
        },
        combatant::{
            CombatantStatsTrait,
            CombatantTrait,
            CombatantStateTrait,
        },
    },
    systems::
        combat::{
            run_effect,
            new_damage_calculation,
        }
};

// #[test]
// fn test_attack() {
//     let mut fighter1 = CombatantState {
//         id: 1,
//         health: 100,
//         stun_chance: 0,
//         buffs: TStats {
//             attack: 10,
//             defense: 5,
//             speed: 0,
//             strength: 0,
//         }
//     };

//     let fighter1_stats = CombatantStats {
//         id: 1,
//         attack: 10,
//         defense: 5,
//         speed: 0,
//         strength: 0,
//     };

//     let mut fighter1_attack_hit = ArrayTrait::new();
//     fighter1_attack_hit.append(Effect {
//         target: Target::Opponent,
//         affect: Affect::Damage(Damage {
//             critical: 10,
//             power: 20
//         })
//     });

//     let mut fighter1_attack_miss = ArrayTrait::new();
//     fighter1_attack_miss.append(Effect {
//         target: Target::Opponent,
//         affect: Affect::Damage(Damage {
//                 critical: 0,
//                 power: 8,
//             }),
//     });

//     let mut fighter1_effect = Effect {
//         target: Target::Opponent,
//         affect: Affect::Damage(Damage {
//             critical: 10,
//             power: 20
//         })
//     };

//     let mut fighter2 = CombatantState {
//         id: 2,
//         health: 100,
//         stun_chance: 0,
//         buffs: TStats {
//             attack: 20,
//             defense: 50,
//             speed: 0,
//             strength: 0,
//         }
//     };

//     let fighter2_stats = CombatantStats {
//         id: 2,
//         attack: 20,
//         defense: 50,
//         speed: 0,
//         strength: 0,
//     };

//     // expected results for the action, if calculation changes, update here
//     let fighter2_assertionResult = CombatantState {
//         id: 2,
//         health: 78,
//         stun_chance: 0,
//         buffs: TStats {
//             attack: 20,
//             defense: 50,
//             speed: 0,
//             strength: 0,
//         }
//     };

//     let fighter1_assertionResult = CombatantStats {
//         id: 1,
//         attack: 10,
//         defense: 5,
//         speed: 0,
//         strength: 0,
//     };

//     let fighter1_attack = fighter1_stats.get_stat(StatTypes::Attack);
//     let fighter1_defense = fighter1_stats.get_stat(StatTypes::Defense);
//     let fighter1_speed = fighter1_stats.get_stat(StatTypes::Speed);
//     let fighter1_strength = fighter1_stats.get_stat(StatTypes::Strength);

//     run_effect(fighter1_stats, fighter2_stats, ref fighter1, ref fighter2, fighter1_effect, 0);
//     assert_eq!(fighter2.health, fighter2_assertionResult.health);
//     assert_eq!(fighter1_attack, fighter1_assertionResult.attack);
//     assert_eq!(fighter1_defense, fighter1_assertionResult.defense);
//     assert_eq!(fighter1_speed, fighter1_assertionResult.speed);
//     assert_eq!(fighter1_strength, fighter1_assertionResult.strength);
// }

// #[test]
// fn test_single_buff() {
//     let mut fighter1 = CombatantState {
//         id: 1,
//         health: 100,
//         stun_chance: 0,
//         buffs: TStats {
//             attack: 10,
//             defense: 5,
//             speed: 0,
//             strength: 0,
//         }
//     };

//     let fighter1_stats = CombatantStats {
//         id: 1,
//         attack: 10,
//         defense: 5,
//         speed: 0,
//         strength: 0,
//     };

//     let fighter1_attackAddition = 50;

//     // expected results for the action, if calculation changes, update here
//     let fighter1_attackValue = 60;

//     fighter1.apply_buff(fighter1_stats, StatTypes::Attack, fighter1_attackAddition);
//     assert_eq!(fighter1.buffs.attack, fighter1_attackValue);
// }



#[test]
fn test_new_damage_calculation() {
    let move_power: u8 = 20;
    let strength: u8 = 30;
    let vitality: u8 = 50;
    let critical: bool = false;

    println!("move_power: {}", move_power);
    println!("strength: {}", strength);
    println!("vitality: {}", vitality);
    println!("critical: {}", critical);

    let damage: u8 = new_damage_calculation(move_power, strength, vitality, critical);
    println!("damage: {}", damage);
    assert_eq!(damage, 13);
}