use alexandria_data_structures::array_ext::ArrayTraitExt;
use starknet::{ContractAddress, get_caller_address};
use dojo::world::{IWorldDispatcher, IWorldDispatcherTrait};
use blob_arena::{
    components::{
        stats::Stats, attack::{Attack, AttackIdsImpl, IdsTrait, AttackTrait},
        item::{Item, ItemTrait, ItemsTrait}
    },
    models::{CombatantInfo, CombatantState, CombatantStats, AvailableAttack}, utils::value_to_uuid,
    collections::CollectionTrait
};

fn get_combatant_id(collection_address: ContractAddress, token_id: u256, combat_id: u128) -> u128 {
    value_to_uuid((collection_address, token_id, combat_id))
}

#[derive(Drop, Copy)]
struct Combatant {
    id: u128,
    combat_id: u128,
    player: ContractAddress,
    collection_address: ContractAddress,
    token_id: u256,
    stats: Stats,
    attacks: Span<u128>,
    health: u8,
    stun_chance: u8,
}

impl CombatantIntoCombatantInfoImpl of Into<Combatant, CombatantInfo> {
    fn into(self: Combatant) -> CombatantInfo {
        CombatantInfo {
            id: self.id,
            combat_id: self.combat_id,
            player: self.player,
            collection_address: self.collection_address,
            token_id: self.token_id
        }
    }
}

impl CombatantIntoCombatantStateImpl of Into<Combatant, CombatantState> {
    fn into(self: Combatant) -> CombatantState {
        CombatantState { id: self.id, health: self.health, stun_chance: self.stun_chance }
    }
}

impl CombatantIntoCombatantStatsImpl of Into<Combatant, CombatantStats> {
    fn into(self: Combatant) -> CombatantStats {
        let Stats { attack, defense, speed, strength } = self.stats;
        CombatantStats { id: self.id, attack, defense, speed, strength }
    }
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
    fn setup_available_attacks(self: IWorldDispatcher, id: u128, attack_ids: Span<u128>) {
        let (len, mut n): (usize, usize) = (attack_ids.len(), 0);
        while n < len {
            self.set_available_attack(id, *attack_ids.at(n), 0);
            n += 1;
        }
    }
    fn create_combatant(
        self: IWorldDispatcher,
        collection_address: ContractAddress,
        token_id: u256,
        combat_id: u128,
        attacks: Span<u128>
    ) -> Combatant {
        let items = self.get_items(collection_address.get_items(token_id));
        let stats = items.get_stats();
        let health = if stats.defense > 155 {
            255
        } else {
            100 + stats.defense
        };

        Combatant {
            id: get_combatant_id(collection_address, token_id, combat_id),
            player: collection_address.owner_of(token_id),
            combat_id,
            collection_address,
            token_id,
            stats,
            attacks,
            health,
            stun_chance: 0,
        }
    }
    fn set_combatant(self: IWorldDispatcher, combatant: Combatant) {
        self.setup_available_attacks(combatant.id, combatant.attacks);
        let info: CombatantInfo = combatant.into();
        let stats: CombatantStats = combatant.into();
        let state: CombatantState = combatant.into();
        set!(self, (info, stats, state));
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
