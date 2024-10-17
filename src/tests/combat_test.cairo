use blob_arena::{
    models::{
        combatant:: {
            CombatantState,
            CombatantInfo,
            CombatantStats 
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
            TStats
        },
    },
    systems::combat::{
        run_effect
    }
};

#[test]
fn test_combat() {
    let mut fighter1 = CombatantState {
        id: 1,
        health: 100,
        stun_chance: 0,
        buffs: TStats {
            attack: 10,
            defense: 5,
            speed: 0,
            strength: 0,
        }
    };

    let fighter1_stats = CombatantStats {
        id: 1,
        attack: 10,
        defense: 5,
        speed: 0,
        strength: 0,
    };

    let mut fighter1_attack_hit = ArrayTrait::new();
    fighter1_attack_hit.append(Effect {
        target: Target::Opponent,
        affect: Affect::Damage(Damage {
            critical: 10,
            power: 20
        })
    });

    let mut fighter1_attack_miss = ArrayTrait::new();
    fighter1_attack_miss.append(Effect {
        target: Target::Opponent,
        affect: Affect::Damage(Damage {
                critical: 0,
                power: 8,
            }),
    });

    let fighter1_attack = Attack {
        id: 1,
        speed: 100,
        name: "test attack 1",
        accuracy: 100,
        cooldown: 0,
        hit: fighter1_attack_hit,
        miss: fighter1_attack_miss,
    };

    let mut fighter1_effect = Effect {
        target: Target::Opponent,
        affect: Affect::Damage(Damage {
            critical: 10,
            power: 20
        })
    };

    let mut fighter2 = CombatantState {
        id: 2,
        health: 100,
        stun_chance: 0,
        buffs: TStats {
            attack: 20,
            defense: 50,
            speed: 0,
            strength: 0,
        }
    };

    let fighter2_stats = CombatantStats {
        id: 2,
        attack: 20,
        defense: 50,
        speed: 0,
        strength: 0,
    };
    
    run_effect(fighter1_stats, fighter2_stats, ref fighter1, ref fighter2, fighter1_effect, 0);
    println!("defender health: {}", fighter2.health);
    println!("defender attack: {}", fighter2.buffs.attack);
    println!("defender defense: {}", fighter2.buffs.defense);
    println!("defender speed: {}", fighter2.buffs.speed);
    println!("defender strength: {}", fighter2.buffs.strength);
}
