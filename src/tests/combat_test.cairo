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

fn stat_effect_span(stat: StatTypes, amount: i8, target: Target) -> Span<Effect> {
    effect_span(Affect::Stat(Stat { stat, amount }), Target::Player)
}

#[test]
fn test_luck_modifier() {
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

    assert_eq!(damage_calculation(100, 0, false), 40);
    assert_eq!(damage_calculation(100, 25, false), 50);
    assert_eq!(damage_calculation(100, 50, false), 60);
    assert_eq!(damage_calculation(100, 75, false), 70);
    assert_eq!(damage_calculation(100, 100, false), 80);

    assert_eq!(damage_calculation(100, 100, true), 160);
}

#[test]
fn test_stun() {
    let mut state_1 = make_combatant_state(1, @STATS_AVG);
    let mut state_2 = make_combatant_state(2, @STATS_AVG);
    let hash_state = make_hash_state(0);

    let mut new_state_1 = state_1;
    let mut new_state_2 = state_2;

    let stun_oppo = effect_span(Affect::Stun(50), Target::Opponent);
    let stun_self = effect_span(Affect::Stun(50), Target::Player);

    run_effects(ref state_1, ref state_2, stun_oppo, hash_state);
    new_state_2.stun_chance = 50;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2));

    run_effects(ref state_1, ref state_2, stun_oppo, hash_state);
    new_state_2.stun_chance = 75;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2));

    run_effects(ref state_1, ref state_2, stun_self, hash_state);
    new_state_1.stun_chance = 50;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2));

    run_effects(ref state_1, ref state_2, stun_self, hash_state);
    new_state_1.stun_chance = 75;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2));
}


#[test]
fn test_buff() {
    let mut state_1 = make_combatant_state(1, @STATS_AVG);
    let mut state_2 = make_combatant_state(2, @STATS_AVG);
    let hash_state = make_hash_state(0);

    let mut new_state_1 = state_1;
    let mut new_state_2 = state_2;

    let effects = stats_effect_span(10, Target::Player);

    run_effects(ref state_1, ref state_2, effects, hash_state);
    new_state_1.stats = 60_u8.into();
    assert_eq!((new_state_1, new_state_2), (state_1, state_2), "round 1");

    run_effects(ref state_1, ref state_2, effects, hash_state);
    new_state_1.stats = 70_u8.into();
    assert_eq!((new_state_1, new_state_2), (state_1, state_2), "round 2");

    run_effects(ref state_1, ref state_2, stats_effect_span(-30, Target::Player), hash_state);
    new_state_1.stats = 40_u8.into();
    new_state_1.health = 140;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2), "round 3");

    run_effects(ref state_1, ref state_2, stats_effect_span(100, Target::Player), hash_state);
    new_state_1.stats = 100_u8.into();
    assert_eq!((new_state_1, new_state_2), (state_1, state_2), "round 4");

    let effect = Effect { target: Target::Player, affect: Affect::Stats((-100_i8).into()) };

    run_effects(ref state_1, ref state_2, array![effect, effect].span(), hash_state);
    new_state_1.stats = 0_u8.into();
    new_state_1.health = 100;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2), "round 5");

    let effects = stats_effect_span(10, Target::Opponent);

    run_effects(ref state_1, ref state_2, effects, hash_state);
    new_state_2.stats = 60_u8.into();
    assert_eq!((new_state_1, new_state_2), (state_1, state_2), "round 6");

    run_effects(ref state_1, ref state_2, effects, hash_state);
    new_state_2.stats = 70_u8.into();
    assert_eq!((new_state_1, new_state_2), (state_1, state_2), "round 7");

    run_effects(ref state_1, ref state_2, stats_effect_span(-30, Target::Opponent), hash_state);
    new_state_2.stats = 40_u8.into();
    new_state_2.health = 140;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2), "round 8");
}

#[test]
fn test_damage() {
    let mut state_1 = make_combatant_state(1, @STATS_AVG);
    let mut state_2 = make_combatant_state(2, @STATS_AVG);
    let hash_state = make_hash_state(0);

    let mut new_state_1 = state_1;
    let mut new_state_2 = state_2;
    let damage_effect = effect_span(
        Affect::Damage(Damage { critical: 0, power: 50, }), Target::Opponent
    );

    run_effects(ref state_1, ref state_2, damage_effect, hash_state);
    new_state_2.health -= 30;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2));

    let damage_effect = effect_span(
        Affect::Damage(Damage { critical: 100, power: 100, }), Target::Opponent
    );
    run_effects(ref state_1, ref state_2, damage_effect, hash_state);
    new_state_2.health = 0;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2));

    let damage_effect = effect_span(
        Affect::Damage(Damage { critical: 0, power: 50, }), Target::Player
    );

    run_effects(ref state_1, ref state_2, damage_effect, hash_state);
    new_state_1.health -= 30;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2));

    let mut state_1 = make_combatant_state(1, @STATS_MAX);
    let mut state_2 = make_combatant_state(2, @STATS_AVG);
    let mut new_state_1 = state_1;
    let mut new_state_2 = state_2;
    let damage_effect = effect_span(
        Affect::Damage(Damage { critical: 0, power: 50, }), Target::Opponent
    );

    run_effects(ref state_1, ref state_2, damage_effect, hash_state);
    new_state_2.health -= 40;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2));
}


fn test_health() {
    let mut state_1 = make_combatant_state(1, @STATS_AVG);
    let mut state_2 = make_combatant_state(2, @STATS_AVG);
    let hash_state = make_hash_state(0);

    let mut new_state_1 = state_1;
    let mut new_state_2 = state_2;

    run_effects(
        ref state_1, ref state_2, effect_span(Affect::Health(-50), Target::Player), hash_state
    );
    new_state_1.health -= 50;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2));

    run_effects(
        ref state_1, ref state_2, effect_span(Affect::Health(-200), Target::Player), hash_state
    );
    new_state_1.health = 0;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2));

    run_effects(
        ref state_1, ref state_2, effect_span(Affect::Health(20), Target::Player), hash_state
    );
    new_state_1.health = 20;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2));

    run_effects(
        ref state_1, ref state_2, effect_span(Affect::Health(200), Target::Player), hash_state
    );
    new_state_1.health = 150;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2));
}


fn test_stat() {
    let mut state_1 = make_combatant_state(1, @STATS_AVG);
    let mut state_2 = make_combatant_state(2, @STATS_AVG);
    let hash_state = make_hash_state(0);

    let mut new_state_1 = state_1;
    let mut new_state_2 = state_2;

    run_effects(
        ref state_1,
        ref state_2,
        stat_effect_span(StatTypes::Dexterity, 100, Target::Player),
        hash_state
    );
    new_state_1.stats.dexterity = 100;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2));

    run_effects(
        ref state_1,
        ref state_2,
        stat_effect_span(StatTypes::Luck, -100, Target::Player),
        hash_state
    );
    new_state_1.stats.luck = 0;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2));

    run_effects(
        ref state_1,
        ref state_2,
        stat_effect_span(StatTypes::Strength, -30, Target::Opponent),
        hash_state
    );
    new_state_2.stats.strength = 20;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2));

    run_effects(
        ref state_1,
        ref state_2,
        stat_effect_span(StatTypes::Vitality, 40, Target::Player),
        hash_state
    );
    new_state_1.stats.vitality = 90;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2));

    run_effects(
        ref state_1,
        ref state_2,
        stat_effect_span(StatTypes::Vitality, -40, Target::Opponent),
        hash_state
    );
    new_state_1.stats.vitality = 10;
    new_state_1.health = 110;
    assert_eq!((new_state_1, new_state_2), (state_1, state_2));
}

