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
        phase_time: u64,
    ) -> u128;
    fn rescind_invite(ref world: IWorldDispatcher, challenge_id: u128);
    fn respond_invite(ref world: IWorldDispatcher, challenge_id: u128, token_id: u256);
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
            combat::{SaltsTrait, Phase, CombatStateTrait, PlannedAttackTrait},
            combatant::{CombatantInfo, CombatantTrait}, commitment::{Commitment,},
            pvp_combat::{PvPCombatTrait, ABStateTrait},
            pvp_challenge::{PvPChallengeTrait, PvPChallengeInvite, PvPChallengeScoreTrait},
            utils::ABTTrait, warrior::{Warrior, WarriorTrait, get_warrior_id},
        },
        systems::pvp_combat::PvPCombatSystemTrait, utils::{uuid, hash_value},
    };
    use super::{IPvPCombatActions, IPvPChallengeActions};
    use core::hash::TupleSize2Hash;

    #[generate_trait]
    impl Private of PrivateTrait {
        fn setup_combatant(
            self: IWorldDispatcher,
            challenge_id: u128,
            collection_address: ContractAddress,
            token_id: u256,
            player: ContractAddress
        ) -> CombatantInfo {
            let combatant = self.create_combatant(collection_address, token_id, challenge_id);
            assert(player == combatant.player, 'Not Owner');
            self.set_combatant(combatant);
            combatant.into()
        }
    }

    #[abi(embed_v0)]
    impl IPvPChallengeActionsImpl of IPvPChallengeActions<ContractState> {
        fn send_invite(
            ref world: IWorldDispatcher,
            receiver: ContractAddress,
            collection_address: ContractAddress,
            token_id: u256,
            phase_time: u64,
        ) -> u128 {
            let challenge_id = uuid(world);
            let caller = get_caller_address();
            let combatant = world
                .setup_combatant(challenge_id, collection_address, token_id, caller);
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
        fn respond_invite(ref world: IWorldDispatcher, challenge_id: u128, token_id: u256) {
            let mut challenge = world.get_open_challenge(challenge_id);
            assert(!challenge.response_open, 'Already responded');

            let caller = challenge.assert_caller_receiver();
            let combatant = world
                .setup_combatant(challenge_id, challenge.collection_address, token_id, caller);

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
            if combat.phase == Phase::Commit {
                let combatants = world.get_pvp_combatants(combat.id);
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
            } else {}
        }
        fn run_round(ref world: IWorldDispatcher, combat_id: u128) {
            let mut combat = world.get_combat_state(combat_id);
            let combatants = world.get_pvp_combatants(combat_id);
            assert(combat.phase == Phase::Reveal, 'Not in reveal phase');

            let planned_attacks = world.get_planned_attacks(combatants.into());
            assert(planned_attacks.check_all_set(), 'Not all attacks revealed');
            world.run_round(combat, planned_attacks);
            // combat_world
            //     .run_round(combat.combatants, attacks, world.get_salts_hash_state(combat_id));
            // combat.phase = Phase::Commit;

            world.clear_planned_attacks(combatants.into());
            world.next_round(combat);
        }
        fn forfeit(
            ref world: IWorldDispatcher, combatant_id: u128
        ) { // let combatant = world.get_combatant_info(combatant_id);
        // let mut combat = world.get_combat_state(combatant_id.combat_id);
        // combat.assert_running();
        // let ab = combat.combatants.get_combatant_ab(warrior_id);
        // let combatant = combat.combatants.get(ab);
        // combatant.assert_player();
        // let winner: PvPWinner = (!ab).into();
        // world.end_game(combat_id, winner);
        // world.update_scores(combat.combatants, winner);
        }
        fn kick_inactive_player(
            ref world: IWorldDispatcher, combatant_id: u128
        ) { // let mut combat = world.get_combat_state(combat_id);
        }
    }
}
