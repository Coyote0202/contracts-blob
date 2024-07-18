use alexandria_data_structures::array_ext::ArrayTraitExt;
use starknet::{ContractAddress, get_caller_address};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    components::{stats::Stats, attack::{Attack, AttackIdsImpl, IdsTrait, AttackTrait},},
    models::{CombatantInfo, CombatantState, CombatantStats, AvailableAttack}, utils::value_to_uuid,
    collections::{get_collection_dispatcher, ICollectionDispatcher, ICollectionDispatcherTrait}
};

fn get_combatant_id(collection_address: ContractAddress, token_id: u256, combat_id: u128) -> u128 {
    value_to_uuid((collection_address, token_id, combat_id))
}


#[generate_trait]
impl CombatantImpl of CombatantTrait {
    fn get_combatant_info(self: @IWorldDispatcher, id: u128) -> CombatantInfo {
        get!((*self), id, CombatantInfo)
    }

    fn get_combatant_state(self: @IWorldDispatcher, id: u128) -> CombatantState {
        get!((*self), id, CombatantState)
    }

    fn get_combatant_stats(self: @IWorldDispatcher, id: u128) -> CombatantStats {
        get!((*self), id, CombatantStats)
    }
    fn get_available_attack(self: @IWorldDispatcher, id: u128, attack_id: u128) -> AvailableAttack {
        get!((*self), (id, attack_id), AvailableAttack)
    }
    fn set_available_attack(
        self: IWorldDispatcher, combatant_id: u128, attack_id: u128, last_used: u32
    ) {
        set!(
            self, AvailableAttack { combatant_id, attack_id, available: true, last_used: last_used }
        );
    }

    fn has_attack(
        self: @IWorldDispatcher,
        collection: ICollectionDispatcher,
        token_id: u256,
        item_id: u128,
        attack_id: u128
    ) -> bool {
        collection.has_attack(token_id, item_id, attack_id)
    }
    fn setup_available_attacks(
        self: IWorldDispatcher,
        collection: ICollectionDispatcher,
        token_id: u256,
        combatant_id: u128,
        attacks: Span<(u128, u128)>
    ) {
        let (len, mut n): (usize, usize) = (attacks.len(), 0);
        while n < len {
            let (item_id, attack_id) = *attacks.at(n);
            if self.has_attack(collection, token_id, item_id, attack_id) {
                self.set_available_attack(combatant_id, attack_id, 0);
            }
            n += 1;
        }
    }
    fn create_combatant(
        self: IWorldDispatcher,
        collection: ICollectionDispatcher,
        token_id: u256,
        combat_id: u128,
        player: ContractAddress,
        attacks: Span<(u128, u128)>
    ) -> CombatantInfo {
        let Stats { attack, defense, speed, strength } = collection.get_stats(token_id);
        let health = collection.get_health(token_id);
        let collection_address = collection.contract_address;
        let combatant_id = get_combatant_id(collection_address, token_id, combat_id);

        self.setup_available_attacks(collection, token_id, combatant_id, attacks);
        let info = CombatantInfo {
            id: combatant_id, combat_id, player, collection_address, token_id,
        };
        let stats = CombatantStats { id: combatant_id, attack, defense, speed, strength };
        let state = CombatantState { id: combatant_id, health, stun_chance: 0 };
        set!(self, (info, stats, state));
        info
    }

    fn get_player_combatant_info(self: @IWorldDispatcher, id: u128) -> CombatantInfo {
        let combatant = self.get_combatant_info(id);
        combatant.assert_player();
        combatant
    }

    fn assert_player(self: CombatantInfo) -> ContractAddress {
        assert(get_caller_address() == self.player, 'Not combatant player'); //#
        self.player
    }
}
