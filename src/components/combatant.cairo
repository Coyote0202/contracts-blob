use alexandria_data_structures::array_ext::ArrayTraitExt;
use core::cmp::{min, max};
use starknet::{ContractAddress, get_caller_address};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    core::{SaturatingInto, SaturatingAdd, in_range}, consts::STARTING_HEALTH,
    components::{
        stats::{Stats, TStats, StatTypes, TStatsTrait},
        attack::{Attack, AttackIdsImpl, IdsTrait, AttackTrait},
    },
    models::{CombatantInfo, CombatantState, CombatantStats, AvailableAttack}, utils::hash_value,
    collections::{get_collection_dispatcher, ICollectionDispatcher, ICollectionDispatcherTrait}
};

fn get_combatant_id(
    collection_address: ContractAddress, token_id: u256, combat_id: felt252
) -> felt252 {
    hash_value((collection_address, token_id, combat_id))
}


#[generate_trait]
impl CombatantImpl of CombatantTrait {
    fn get_combatant_info(self: @IWorldDispatcher, id: felt252) -> CombatantInfo {
        get!((*self), id, CombatantInfo)
    }

    fn get_combatant_state(self: @IWorldDispatcher, id: felt252) -> CombatantState {
        get!((*self), id, CombatantState)
    }

    fn get_combatant_stats(self: @IWorldDispatcher, id: felt252) -> CombatantStats {
        get!((*self), id, CombatantStats)
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
        let Stats { strength, vitality, dexterity, luck } = collection.get_stats(token_id);
        let health = collection.get_health(token_id);
        let collection_address = collection.contract_address;
        let combatant_id = get_combatant_id(collection_address, token_id, combat_id);

        self.setup_available_attacks(collection, token_id, combatant_id, attacks);
        let info = CombatantInfo {
            id: combatant_id, combat_id, player, collection_address, token_id,
        };
        let stats = CombatantStats { id: combatant_id, strength, vitality, dexterity, luck };
        let state = CombatantState {
            id: combatant_id, health, stun_chance: 0, buffs: Default::default()
        };
        set!(self, (info, stats, state));
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

    fn create_new_state(self: @CombatantStats) -> CombatantState {
        CombatantState {
            id: *self.id, health: 100 + *self.vitality, stun_chance: 0, buffs: Default::default(),
        }
    }
}


fn make_stat_in_range(base: u8, buff: i8) -> i8 {
    in_range(-(base).try_into().unwrap(), (100 - base).try_into().unwrap(), buff)
}

#[generate_trait]
impl CombatantStateImpl of CombatantStateTrait {
    fn limit_buffs(ref self: CombatantState, stats: @CombatantStats) {
        self
            .buffs =
                TStats {
                    strength: make_stat_in_range(*stats.strength, self.buffs.strength),
                    vitality: make_stat_in_range(*stats.vitality, self.buffs.vitality),
                    dexterity: make_stat_in_range(*stats.dexterity, self.buffs.dexterity),
                    luck: make_stat_in_range(*stats.luck, self.buffs.luck),
                }
    }

    fn apply_buffs(ref self: CombatantState, stats: @CombatantStats, buff: @TStats<i8>) {
        self.buffs = self.buffs.saturating_add(*buff);
        self.limit_buffs(stats);
    }

    fn modify_health(ref self: CombatantState, stats: @CombatantStats, health: i16) {
        self
            .health =
                min(stats.get_max_health(@self), (self.health.into() + health).saturating_into());
    }

    fn apply_buff(ref self: CombatantState, stats: @CombatantStats, stat: StatTypes, amount: i8) {
        self
            .buffs
            .set_stat(
                stat,
                make_stat_in_range(
                    stats.get_stat(stat),
                    self.buffs.get_stat(stat).try_into().unwrap().saturating_add(amount)
                )
            );
    }
}

#[generate_trait]
impl CombatantStatsImpl of CombatantStatsTrait {
    fn get_buffed_stats(self: @CombatantStats, state: @CombatantState) -> TStats<u8> {
        TStats::<
            u8
        > {
            strength: self.get_strength(state),
            vitality: self.get_vitality(state),
            dexterity: self.get_dexterity(state),
            luck: self.get_luck(state),
        }
    }

    fn get_stat(self: @CombatantStats, stat: StatTypes) -> u8 {
        match stat {
            StatTypes::Strength => *self.strength,
            StatTypes::Vitality => *self.vitality,
            StatTypes::Dexterity => *self.dexterity,
            StatTypes::Luck => *self.luck,
        }
    }

    fn get_max_health(self: @CombatantStats, state: @CombatantState) -> u8 {
        ((*self.vitality + STARTING_HEALTH).try_into().unwrap() + *state.buffs.vitality)
            .saturating_into()
    }

    fn get_luck(self: @CombatantStats, state: @CombatantState) -> u8 {
        ((*self.luck).try_into().unwrap() + *state.buffs.luck).saturating_into()
    }
    fn get_strength(self: @CombatantStats, state: @CombatantState) -> u8 {
        ((*self.strength).try_into().unwrap() + *state.buffs.strength).saturating_into()
    }
    fn get_vitality(self: @CombatantStats, state: @CombatantState) -> u8 {
        ((*self.vitality).try_into().unwrap() + *state.buffs.vitality).saturating_into()
    }
    fn get_dexterity(self: @CombatantStats, state: @CombatantState) -> u8 {
        ((*self.dexterity).try_into().unwrap() + *state.buffs.dexterity).saturating_into()
    }
}
