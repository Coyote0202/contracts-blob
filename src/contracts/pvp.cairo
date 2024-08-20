use starknet::ContractAddress;
use dojo::world::{IWorldDispatcher};

#[dojo::interface]
trait IPvPCombatActions {
    fn commit_attack(ref world: IWorldDispatcher, combatant_id: u128, hash: felt252);
    fn reveal_attack(ref world: IWorldDispatcher, combatant_id: u128, attack: u128, salt: felt252);
    fn run_round(ref world: IWorldDispatcher, combat_id: u128);
    fn forfeit(ref world: IWorldDispatcher, combatant_id: u128);
    fn kick_inactive_player(ref world: IWorldDispatcher, combatant_id: u128);
}

#[dojo::interface]
trait IPvPChallengeActions {
    fn send_invite(
        ref world: IWorldDispatcher,
        receiver: ContractAddress,
        collection_address: ContractAddress,
        token_id: u256,
        attacks: Span<(u128, u128)>,
        phase_time: u64
    ) -> u128;
    fn rescind_invite(ref world: IWorldDispatcher, challenge_id: u128);
    fn respond_invite(
        ref world: IWorldDispatcher, challenge_id: u128, token_id: u256, attacks: Span<(u128, u128)>
    );
    fn rescind_response(ref world: IWorldDispatcher, challenge_id: u128);
    fn reject_invite(ref world: IWorldDispatcher, challenge_id: u128);
    fn reject_response(ref world: IWorldDispatcher, challenge_id: u128);
    fn accept_response(ref world: IWorldDispatcher, challenge_id: u128);
}


#[dojo::contract]
mod pvp_actions {
    use starknet::{ContractAddress, get_caller_address};
    use blob_arena::{
        components::{
            combat::{
                SaltsTrait, Phase, CombatStateTrait, CombatStatesTrait, PlannedAttack,
                PlannedAttackTrait
            },
            combatant::{CombatantInfo, CombatantTrait,}, commitment::{Commitment,},
            pvp_combat::{PvPCombatTrait},
            pvp_challenge::{PvPChallengeTrait, PvPChallengeInvite, PvPChallengeScoreTrait},
            utils::{ABTTrait, ABT, ABTOtherTrait}
        },
        collections::{get_collection_dispatcher, ICollectionDispatcher, ICollectionDispatcherTrait},
        systems::pvp_combat::PvPCombatSystemTrait, utils::{uuid, hash_value},
    };
    use super::{IPvPCombatActions, IPvPChallengeActions};

    #[abi(embed_v0)]
    impl IPvPChallengeActionsImpl of IPvPChallengeActions<ContractState> {
        fn send_invite(
            ref world: IWorldDispatcher,
            receiver: ContractAddress,
            collection_address: ContractAddress,
            token_id: u256,
            attacks: Span<(u128, u128)>,
            phase_time: u64,
        ) -> u128 {
            let challenge_id = uuid(world);
            let caller = get_caller_address();
            let combatant = world
                .create_player_combatant(
                    collection_address, token_id, challenge_id, caller, attacks
                );
            world
                .send_challenge_invite(
                    challenge_id, caller, receiver, collection_address, combatant.id, phase_time,
                );
            challenge_id
        }
        fn rescind_invite(ref world: IWorldDispatcher, challenge_id: u128) {
            let mut challenge = world.get_open_challenge(challenge_id);
            challenge.assert_caller_sender();
            challenge.invite_open = false;
            world.set_challenge_invite(challenge);
        }
        fn respond_invite(
            ref world: IWorldDispatcher,
            challenge_id: u128,
            token_id: u256,
            attacks: Span<(u128, u128)>
        ) {
            let mut challenge = world.get_open_challenge(challenge_id);
            assert(!challenge.response_open, 'Already responded');

            let caller = challenge.assert_caller_receiver();
            let combatant = world
                .create_player_combatant(
                    challenge.collection_address, token_id, challenge_id, caller, attacks
                );

            challenge.receiver_combatant = combatant.id;
            challenge.response_open = true;
            world.set_challenge_response(challenge);
        }
        fn rescind_response(ref world: IWorldDispatcher, challenge_id: u128) {
            let mut challenge = world.get_open_challenge(challenge_id);
            challenge.assert_caller_receiver();
            assert(challenge.response_open, 'Response already closed');
            challenge.response_open = false;
            world.set_challenge_response(challenge);
        }
        fn reject_invite(ref world: IWorldDispatcher, challenge_id: u128) {
            let mut challenge = world.get_open_challenge(challenge_id);
            challenge.assert_caller_receiver();
            challenge.invite_open = false;
            world.set_challenge_invite(challenge);
        }
        fn reject_response(ref world: IWorldDispatcher, challenge_id: u128) {
            let mut challenge = world.get_open_challenge(challenge_id);
            challenge.assert_caller_receiver();
            challenge.invite_open = false;
            world.set_challenge_invite(challenge);
        }
        fn accept_response(ref world: IWorldDispatcher, challenge_id: u128) {
            let mut challenge = world.get_open_challenge(challenge_id);
            challenge.assert_caller_sender();
            assert(challenge.response_open, 'Response already closed');
            world.create_game(challenge);
        }
    }
    #[abi(embed_v0)]
    impl PvPActionsImpl of IPvPCombatActions<ContractState> {
        fn commit_attack(ref world: IWorldDispatcher, combatant_id: u128, hash: felt252) {
            let combatant = world.get_combatant_info(combatant_id);
            let combat = world.get_combat_state(combatant.combat_id);
            assert(combat.phase == Phase::Commit, 'Not in commit phase');

            combatant.assert_player();
            world.set_new_commitment_with(combatant_id, hash);
        }
        fn reveal_attack(
            ref world: IWorldDispatcher, combatant_id: u128, attack: u128, salt: felt252
        ) {
            let combatant = world.get_combatant_info(combatant_id);
            combatant.assert_player();
            let mut combat = world.get_combat_state(combatant.combat_id);
            let combatants = world.get_pvp_combatants(combat.id);
            if combat.phase == Phase::Commit {
                if world.check_commitments_set_with(combatants.into()) {
                    combat.phase = Phase::Reveal;
                    set!(world, (combat,))
                };
            };
            assert(combat.phase == Phase::Reveal, 'Not in reveal phase');
            let hash = hash_value((attack, salt));
            let commitment = world.get_commitment_with(combatant_id);
            if hash == commitment {
                world.append_salt(combat.id, salt);
                let other_combatant = combatants.other(combatant_id);
                let planned_attack = PlannedAttack {
                    id: combatant_id, attack, target: other_combatant,
                };
                world.set_planned_attack(planned_attack);
            } else {
                let winner_id = combatants.other(combatant_id);
                world.end_combat(combat, winner_id);
                world.update_scores(world.get_combatant_info(winner_id), combatant);
            }
        }
        fn run_round(ref world: IWorldDispatcher, combat_id: u128) {
            let mut combat = world.get_combat_state(combat_id);
            let combatants = world.get_pvp_combatants(combat_id);
            let combatants_span: Span<u128> = combatants.into();
            assert(combat.phase == Phase::Reveal, 'Not in reveal phase');
            let hash = world.get_salts_hash_state(combat_id);
            let planned_attacks = world.get_planned_attacks(combatants_span);
            assert(planned_attacks.check_all_set(), 'Not all attacks revealed');
            let states = world
                .run_round(combatants, planned_attacks.try_into().unwrap(), combat.round, hash);
            let (alive, dead) = states.get_combatants_mortality();
            if (alive.len() > 1) {
                world.next_round(combat, combatants_span);
            } else {
                let winner_id = *alive.at(0);
                let winner = world.get_combatant_info(winner_id);
                let looser = world.get_combatant_info(*dead.at(0));

                world.end_combat(combat, winner_id);
                world.update_scores(winner, looser);
            }
        }
        fn forfeit(ref world: IWorldDispatcher, combatant_id: u128) {
            let loser = world.get_combatant_info(combatant_id);
            loser.assert_player();
            let mut combat = world.get_running_combat_state(loser.combat_id);
            let combatants = world.get_pvp_combatants(combat.id);
            let winner_id = combatants.other(loser.id);
            let winner = world.get_combatant_info(winner_id);
            world.end_combat(combat, winner_id);
            world.update_scores(winner, loser);
        }
        fn kick_inactive_player(
            ref world: IWorldDispatcher, combatant_id: u128
        ) { // let mut combat = world.get_combat_state(combat_id);
        }
    }
}
