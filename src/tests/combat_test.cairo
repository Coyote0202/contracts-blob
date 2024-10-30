use core::fmt::Debug;
use blob_arena::{
    models::{
        combatant::{CombatantState, CombatantInfo,},
        attack::{Attack, Affect, Effect, Damage, Target, Stat, Stats as BStats},
    },
    components::{
        stats::{TStats, StatTypes, Stats},
        combatant::{make_combatant_state, CombatantTrait, CombatantStateTrait,},
    },
    systems::combat::{run_effects, apply_luck_modifier, damage_calculation}, utils::make_hash_state,
};

const STATS_AVG: Stats = Stats { strength: 50, vitality: 50, dexterity: 50, luck: 50, };

const STATS_MAX: Stats = Stats { strength: 100, vitality: 100, dexterity: 100, luck: 100, };

const STATS_WEAK: Stats = Stats { strength: 10, vitality: 10, dexterity: 10, luck: 10, };

fn stats_effect_span(value: i8, target: Target) -> Span<Effect> {
    effect_span(Affect::Stats(value.into()), target)
}

fn effect_span(affect: Affect, target: Target) -> Span<Effect> {
    array![Effect { target, affect }].span()
}

#[test]
fn test_luck_modifier() {
    // let (l1, l2, l3): (u8, u8, u8) = (
    //     apply_luck_modifier(10, 0), apply_luck_modifier(50, 0), apply_luck_modifier(90, 0)
    // );
    // println!("chance {:?} {:?} {:?}", l1, l2, l3);

    // let (l1, l2, l3): (u8, u8, u8) = (
    //     apply_luck_modifier(10, 25), apply_luck_modifier(50, 25), apply_luck_modifier(90, 25)
    // );
    // println!("chance {:?} {:?} {:?}", l1, l2, l3);

    // let (l1, l2, l3): (u8, u8, u8) = (
    //     apply_luck_modifier(10, 75), apply_luck_modifier(50, 75), apply_luck_modifier(90, 75)
    // );
    // println!("chance {:?} {:?} {:?}", l1, l2, l3);

    // let (l1, l2, l3): (u8, u8, u8) = (
    //     apply_luck_modifier(10, 100), apply_luck_modifier(50, 100), apply_luck_modifier(90, 100)
    // );
    // println!("chance {:?} {:?} {:?}", l1, l2, l3);

    assert_eq!(0_u8, apply_luck_modifier(0, 0));
    assert_eq!(8_u8, apply_luck_modifier(10, 0));
    assert_eq!(90_u8, apply_luck_modifier(50, 0));
    assert_eq!(217_u8, apply_luck_modifier(90, 0));
    assert_eq!(255_u8, apply_luck_modifier(100, 0));

    assert_eq!(0_u8, apply_luck_modifier(0, 25));
    assert_eq!(15_u8, apply_luck_modifier(10, 25));
    assert_eq!(109_u8, apply_luck_modifier(50, 25));
    assert_eq!(224_u8, apply_luck_modifier(90, 25));
    assert_eq!(255_u8, apply_luck_modifier(100, 25));

    assert_eq!(0_u8, apply_luck_modifier(0, 50));
    assert_eq!(25_u8, apply_luck_modifier(10, 50));
    assert_eq!(127_u8, apply_luck_modifier(50, 50));
    assert_eq!(229_u8, apply_luck_modifier(90, 50));
    assert_eq!(255_u8, apply_luck_modifier(100, 50));

    assert_eq!(0_u8, apply_luck_modifier(0, 75));
    assert_eq!(38_u8, apply_luck_modifier(10, 75));
    assert_eq!(144_u8, apply_luck_modifier(50, 75));
    assert_eq!(233_u8, apply_luck_modifier(90, 75));
    assert_eq!(255_u8, apply_luck_modifier(100, 75));

    assert_eq!(0_u8, apply_luck_modifier(0, 100));
    assert_eq!(54_u8, apply_luck_modifier(10, 100));
    assert_eq!(160_u8, apply_luck_modifier(50, 100));
    assert_eq!(237_u8, apply_luck_modifier(90, 100));
    assert_eq!(255_u8, apply_luck_modifier(100, 100));
}

#[test]
fn test_damage_calculation() {
    assert_eq!(damage_calculation(0, 0, false), 0);
    assert_eq!(damage_calculation(0, 100, false), 0);
    assert_eq!(damage_calculation(0, 100, true), 0);

    assert_eq!(damage_calculation(25, 0, false), 10);
    assert_eq!(damage_calculation(25, 25, false), 12);
    assert_eq!(damage_calculation(25, 50, false), 15);
    assert_eq!(damage_calculation(25, 75, false), 17);
    assert_eq!(damage_calculation(25, 100, false), 20);

    assert_eq!(damage_calculation(50, 0, false), 20);
    assert_eq!(damage_calculation(50, 25, false), 25);
    assert_eq!(damage_calculation(50, 50, false), 30);
    assert_eq!(damage_calculation(50, 75, false), 35);
    assert_eq!(damage_calculation(50, 100, false), 40);

    assert_eq!(damage_calculation(75, 0, false), 30);
    assert_eq!(damage_calculation(75, 25, false), 37);
    assert_eq!(damage_calculation(75, 50, false), 45);
    assert_eq!(damage_calculation(75, 75, false), 52);
    assert_eq!(damage_calculation(75, 100, false), 60);

    assert_eq!(damage_calculation(100, 100, false), 80);
    assert_eq!(damage_calculation(100, 100, true), 160);
}

#[test]
fn test_stun() {
    let mut state_1 = make_combatant_state(1, @STATS_AVG);
    let mut state_2 = make_combatant_state(2, @STATS_AVG);
    let hash_state = make_hash_state(0);

    let mut new_1_state = state_1;
    let mut new_2_state = state_2;

    let stun_oppo = effect_span(Affect::Stun(50), Target::Opponent);
    let stun_self = effect_span(Affect::Stun(50), Target::Player);

    run_effects(ref state_1, ref state_2, stun_oppo, hash_state);
    new_2_state.stun_chance = 50;
    assert_eq!((new_1_state, new_2_state), (state_1, state_2));

    run_effects(ref state_1, ref state_2, stun_oppo, hash_state);
    new_2_state.stun_chance = 75;
    assert_eq!((new_1_state, new_2_state), (state_1, state_2));

    run_effects(ref state_1, ref state_2, stun_self, hash_state);
    new_1_state.stun_chance = 50;
    assert_eq!((new_1_state, new_2_state), (state_1, state_2));

    run_effects(ref state_1, ref state_2, stun_self, hash_state);
    new_1_state.stun_chance = 75;
    assert_eq!((new_1_state, new_2_state), (state_1, state_2));
}


#[test]
fn test_buff() {
    let mut state_1 = make_combatant_state(1, @STATS_AVG);
    let mut state_2 = make_combatant_state(2, @STATS_AVG);
    let hash_state = make_hash_state(0);

    let mut new_1_state = state_1;
    let mut new_2_state = state_2;

    let effects = stats_effect_span(10, Target::Player);

    run_effects(ref state_1, ref state_2, effects, hash_state);
    new_1_state.stats = 60_u8.into();
    assert_eq!((new_1_state, new_2_state), (state_1, state_2), "round 1");

    run_effects(ref state_1, ref state_2, effects, hash_state);
    new_1_state.stats = 70_u8.into();
    assert_eq!((new_1_state, new_2_state), (state_1, state_2), "round 2");

    run_effects(ref state_1, ref state_2, stats_effect_span(-30, Target::Player), hash_state);
    new_1_state.stats = 40_u8.into();
    new_1_state.health = 140;
    assert_eq!((new_1_state, new_2_state), (state_1, state_2), "round 3");

    run_effects(ref state_1, ref state_2, stats_effect_span(100, Target::Player), hash_state);
    new_1_state.stats = 100_u8.into();
    assert_eq!((new_1_state, new_2_state), (state_1, state_2), "round 4");

    let effect = Effect { target: Target::Player, affect: Affect::Stats((-100_i8).into()) };

    run_effects(ref state_1, ref state_2, array![effect, effect].span(), hash_state);
    new_1_state.stats = 0_u8.into();
    new_1_state.health = 100;
    assert_eq!((new_1_state, new_2_state), (state_1, state_2), "round 5");

    let effects = stats_effect_span(10, Target::Opponent);

    run_effects(ref state_1, ref state_2, effects, hash_state);
    new_2_state.stats = 60_u8.into();
    assert_eq!((new_1_state, new_2_state), (state_1, state_2), "round 6");

    run_effects(ref state_1, ref state_2, effects, hash_state);
    new_2_state.stats = 70_u8.into();
    assert_eq!((new_1_state, new_2_state), (state_1, state_2), "round 7");

    run_effects(ref state_1, ref state_2, stats_effect_span(-30, Target::Opponent), hash_state);
    new_2_state.stats = 40_u8.into();
    new_2_state.health = 140;
    assert_eq!((new_1_state, new_2_state), (state_1, state_2), "round 8");
}

#[test]
fn test_damage_self() {
    let mut state_1 = make_combatant_state(1, @STATS_AVG);
    let mut state_2 = make_combatant_state(2, @STATS_AVG);
    let hash_state = make_hash_state(0);

    let mut new_1_state = state_1;
    let mut new_2_state = state_2;
    let damage_effect = effect_span(
        Affect::Damage(Damage { critical: 0, power: 50, }), Target::Opponent
    );

    run_effects(ref state_1, ref state_2, damage_effect, hash_state);
    new_2_state.health -= 30;

    assert_eq!((new_1_state, new_2_state), (state_1, state_2));
}
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


