use alexandria_data_structures::array_ext::ArrayTraitExt;
use core::cmp::{min, max};
use starknet::{ContractAddress, get_caller_address};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    core::{SaturatingInto, SaturatingAdd, in_range}, consts::STARTING_HEALTH,
    components::{
        stats::{Stats, TStats, StatTypes, TStatsTrait, StatsTrait},
        attack::{Attack, AttackIdsImpl, IdsTrait, AttackTrait},
    },
    models::{CombatantInfo, CombatantState, AvailableAttack}, utils::hash_value,
    collections::{get_collection_dispatcher, ICollectionDispatcher, ICollectionDispatcherTrait}
};

fn get_combatant_id(
    collection_address: ContractAddress, token_id: u256, combat_id: felt252
) -> felt252 {
    hash_value((collection_address, token_id, combat_id))
}

fn max_health(vitality: u8) -> u8 {
    (vitality + STARTING_HEALTH).saturating_into()
}

fn make_combatant_state(id: felt252, stats: @Stats) -> CombatantState {
    CombatantState { id, health: max_health(*stats.vitality), stun_chance: 0, stats: *stats }
}

#[generate_trait]
impl CombatantImpl of CombatantTrait {
    fn get_combatant_info(self: @IWorldDispatcher, id: felt252) -> CombatantInfo {
        get!((*self), id, CombatantInfo)
    }

    fn get_combatant_state(self: @IWorldDispatcher, id: felt252) -> CombatantState {
        get!((*self), id, CombatantState)
    }
    fn get_available_attack(
        self: @IWorldDispatcher, id: felt252, attack_id: felt252
    ) -> AvailableAttack {
        get!((*self), (id, attack_id), AvailableAttack)
    }
    fn set_available_attack(
        self: IWorldDispatcher, combatant_id: felt252, attack_id: felt252, last_used: u32
    ) {
        set!(
            self, AvailableAttack { combatant_id, attack_id, available: true, last_used: last_used }
        );
    }
    fn get_combatant_info_in_combat(self: @IWorldDispatcher, id: felt252) -> CombatantInfo {
        let combatant = self.get_combatant_info(id);
        assert(combatant.combat_id.is_non_zero(), 'Not valid combatant');
        combatant
    }
    fn has_attack(
        self: @IWorldDispatcher,
        collection: ICollectionDispatcher,
        token_id: u256,
        item_id: felt252,
        attack_id: felt252
    ) -> bool {
        collection.has_attack(token_id, item_id, attack_id)
    }
    fn setup_available_attacks(
        self: IWorldDispatcher,
        collection: ICollectionDispatcher,
        token_id: u256,
        combatant_id: felt252,
        attacks: Span<(felt252, felt252)>
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
        combat_id: felt252,
        player: ContractAddress,
        attacks: Span<(felt252, felt252)>
    ) -> CombatantInfo {
        let collection_address = collection.contract_address;
        let combatant_id = get_combatant_id(collection_address, token_id, combat_id);

        self.setup_available_attacks(collection, token_id, combatant_id, attacks);
        let info = CombatantInfo {
            id: combatant_id, combat_id, player, collection_address, token_id,
        };
        let stats: Stats = collection.get_stats(token_id);
        set!(self, (info, make_combatant_state(combatant_id, @stats)));
        info
    }

    fn create_player_combatant(
        self: IWorldDispatcher,
        collection_address: ContractAddress,
        token_id: u256,
        challenge_id: felt252,
        player: ContractAddress,
        attacks: Span<(felt252, felt252)>
    ) -> CombatantInfo {
        let collection = get_collection_dispatcher(collection_address);
        let owner = collection.get_owner(token_id);
        assert(player == owner, 'Not Owner');
        self.create_combatant(collection, token_id, challenge_id, player, attacks)
    }

    fn get_player_combatant_info(self: @IWorldDispatcher, id: felt252) -> CombatantInfo {
        let combatant = self.get_combatant_info(id);
        combatant.assert_player();
        combatant
    }

    fn assert_player(self: CombatantInfo) -> ContractAddress {
        assert(get_caller_address() == self.player, 'Not combatant player'); //#
        self.player
    }
}


fn make_stat_in_range(base: u8, buff: i8) -> i8 {
    in_range(-(base).try_into().unwrap(), (100 - base).try_into().unwrap(), buff)
}

#[generate_trait]
impl CombatantStateImpl of CombatantStateTrait {
    fn limit_buffs(ref self: CombatantState) {
        self.stats.limit_stats();
    }

    fn apply_buffs(ref self: CombatantState, buffs: @TStats<i8>) {
        self.stats.apply_buffs(buffs);
        self.cap_health();
    }

    fn modify_health<T, +Into<u8, T>, +SaturatingAdd<T>, +SaturatingInto<T, u8>, +Drop<T>>(
        ref self: CombatantState, health: T
    ) {
        self
            .health =
                min(
                    self.get_max_health(),
                    self.health.into().saturating_add(health).saturating_into()
                );
    }

    fn apply_buff(ref self: CombatantState, stat: StatTypes, amount: i8) {
        self.stats.apply_buff(stat, amount);
        if stat == StatTypes::Vitality {
            self.cap_health();
        };
    }

    fn cap_health(ref self: CombatantState) {
        self.health = min(self.get_max_health(), self.health);
    }

    fn get_max_health(self: @CombatantState) -> u8 {
        self.stats.get_max_health()
    }
}
