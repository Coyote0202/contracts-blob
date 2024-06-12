use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher};

#[starknet::interface]
trait IPvPActions<TContractState> {
    fn commit_attack(
        self: @TContractState,
        world: IWorldDispatcher,
        combat_id: u128,
        warrior_id: u128,
        hash: felt252
    );
    fn reveal_attack(
        self: @TContractState,
        world: IWorldDispatcher,
        combat_id: u128,
        warrior_id: u128,
        attack: u128,
        salt: felt252
    );
}

#[starknet::contract]
mod pvp_actions {
    use starknet::{ContractAddress, get_caller_address};
    use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
    use blob_arena::{
        components::{
            combat::{SaltsTrait, Phase}, combatant::CombatantTrait,
            commitment::{Commitment, hash_value},
            pvp_combat::{PvPCombatTrait, ABBool, ABStateTrait, ABCombatatTrait}, utils::ABTTrait,
        }
    };
    use super::{IPvPActions};
    use core::hash::TupleSize2Hash;


    #[storage]
    struct Storage {}
    #[abi(embed_v0)]
    impl PvPActionsImpl of IPvPActions<ContractState> {
        fn commit_attack(
            self: @ContractState,
            world: IWorldDispatcher,
            combat_id: u128,
            warrior_id: u128,
            hash: felt252
        ) {
            let mut combat = world.get_pvp_combat(combat_id);
            assert(combat.phase == Phase::Commit, 'Not in commit phase');

            let ab = combat.combatants.get_combatant_ab(warrior_id);
            let combatant = combat.combatants.get(ab);

            combatant.assert_player();
            assert(combat.players_state.get(ab), 'Attack Already Committed');
            let set = combat.players_state.get(!ab);

            world.set_commitment_with((combat_id, warrior_id), hash);

            if set {
                combat.players_state.set(!ab, false);
                combat.phase = Phase::Reveal;
            } else {
                combat.players_state.set(ab, true);
            }

            world.set_pvp_combat_state(combat);
        }
        fn reveal_attack(
            self: @ContractState,
            world: IWorldDispatcher,
            combat_id: u128,
            warrior_id: u128,
            attack: u128,
            salt: felt252
        ) {
            let mut combat = world.get_pvp_combat(combat_id);
            assert(combat.phase == Phase::Reveal, 'Not in reveal phase');

            let ab = combat.combatants.get_combatant_ab(warrior_id);
            let combatant = combat.combatants.get(ab);
            combatant.assert_player();
            assert(combat.players_state.get(ab), 'Attack Already Revealed');

            let hash = hash_value((attack, salt));
            let commitment = world.get_commitment_with((combat_id, warrior_id));
            if hash == commitment {
                world.append_salt(combat_id, salt);
                world.set_planned_attack(combat_id, warrior_id, attack);
                combat.players_state.set(ab, true);
            } else {
                combat.end_game()
            }
        }
    }
}
