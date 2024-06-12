use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::components::{attack::{Attack, AttackTrait}, combatant::Combatant};

#[generate_trait]
impl AttackSystemImpl of AttackSystemTrait {
    fn run_cooldown(
        self: @IWorldDispatcher, combatant: Combatant, attack: Attack, round: u32
    ) -> bool {
        if attack.cooldown == 0 {
            return true;
        }
        let last_use = self
            .get_attack_last_use(combatant.combat_id, combatant.warrior_id, attack.id);
        if last_use.is_non_zero() && (attack.cooldown.into() + last_use) > round {
            return false;
        };
        self.set_attack_last_used(combatant.combat_id, combatant.warrior_id, attack.id, round);
        true
    }
}
