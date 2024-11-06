use core::{
    fmt::{Display, Formatter, Error}, hash::{HashStateTrait, HashStateExTrait, Hash},
    poseidon::{poseidon_hash_span, PoseidonTrait, HashState}
};
use starknet::{ContractAddress, get_block_number};
use dojo::{world::{IWorldDispatcher, IWorldDispatcherTrait}, model::Model};
use blob_arena::{
    components::{utils::{ABT, Status, Winner}, commitment::Commitment},
    models::{
        SaltsModel, Phase, CombatState, CombatStateStore, PlannedAttack, PlannedAttackStore,
        CombatantState, Target
    },
    utils::ArrayHash
};
type Salts = Array<felt252>;

#[derive(Drop, Serde, PartialEq, Introspect)]
enum AffectResult {
    Success,
    Damage: DamageResult,
}

#[derive(Drop, Serde, PartialEq, Introspect)]
struct DamageResult {
    move: u8,
    target: Target,
    damage: u8,
    critical: bool,
}

#[generate_trait]
impl SaltsImpl of SaltsTrait {
    fn get_salts_model(self: IWorldDispatcher, id: felt252) -> SaltsModel {
        get!(self, id, SaltsModel)
    }

    fn set_salts(self: IWorldDispatcher, id: felt252, salts: Salts) {
        set!(self, (SaltsModel { id, salts: salts },));
    }

    fn append_salt(self: IWorldDispatcher, id: felt252, salt: felt252) {
        let mut salts = self.get_salts(id);
        salts.append(salt);
        self.set_salts(id, salts);
    }

    fn reset_salts(self: IWorldDispatcher, id: felt252) {
        set!(self, (SaltsModel { id, salts: array![] }));
    }
    fn get_salts(self: IWorldDispatcher, id: felt252) -> Salts {
        self.get_salts_model(id).salts
    }


    fn get_salts_hash(self: IWorldDispatcher, id: felt252) -> felt252 {
        poseidon_hash_span(self.get_salts(id).span())
    }

    fn get_salts_hash_state(self: IWorldDispatcher, id: felt252) -> HashState {
        PoseidonTrait::new().update_with(self.get_salts(id))
    }
}

#[generate_trait]
impl PhaseImpl of PhaseTrait {
    fn assert_running(self: @Phase) {
        assert(self.is_running(), 'Combat not running')
    }
    fn is_running(self: @Phase) -> bool {
        match *self {
            Phase::Commit | Phase::Reveal => true,
            _ => false
        }
    }
}

#[generate_trait]
impl CombatStateImpl of CombatStateTrait {
    fn get_combat_state(self: @IWorldDispatcher, id: felt252) -> CombatState {
        CombatStateStore::get(*self, id)
    }
    fn new_combat_state(self: IWorldDispatcher, id: felt252) {
        CombatState { id, phase: Phase::Commit, round: 1, block_number: get_block_number() }
            .set(self)
    }
    fn get_combat_phase(self: @IWorldDispatcher, id: felt252) -> Phase {
        self.get_combat_state(id).phase
    }
    fn get_running_combat_state(self: @IWorldDispatcher, id: felt252) -> CombatState {
        let state = self.get_combat_state(id);
        state.phase.assert_running();
        state
    }
    fn next_round(self: IWorldDispatcher, mut state: CombatState, combatants: Span<felt252>) {
        self.reset_salts(state.id);
        self.clear_commitments_with(combatants);
        self.clear_planned_attacks(combatants);
        state.round += 1;
        state.phase = Phase::Commit;
        state.set(self);
    }
}
#[generate_trait]
impl CombatStatesImpl of CombatStatesTrait {
    fn get_combatants_mortality(
        mut self: Array<CombatantState>
    ) -> (Array<felt252>, Array<felt252>) {
        let mut alive = ArrayTrait::<felt252>::new();
        let mut dead = ArrayTrait::<felt252>::new();
        loop {
            match self.pop_front() {
                Option::Some(state) => {
                    if state.health.is_non_zero() {
                        alive.append(state.id);
                    } else {
                        dead.append(state.id);
                    }
                },
                Option::None => { break; }
            }
        };
        (alive, dead)
    }
    fn end_combat(self: IWorldDispatcher, mut state: CombatState, winner: felt252) {
        state.phase = Phase::Ended(winner);
        state.set(self);
    }
}


#[generate_trait]
impl PlannedAttackImpl of PlannedAttackTrait {
    fn get_planned_attack(self: @IWorldDispatcher, id: felt252) -> PlannedAttack {
        PlannedAttackStore::get(*self, id)
    }
    fn get_planned_attacks(self: @IWorldDispatcher, ids: Span<felt252>) -> Span<PlannedAttack> {
        let (mut n, len) = (0, ids.len());
        let mut attacks = ArrayTrait::<PlannedAttack>::new();
        while n < len {
            attacks.append(self.get_planned_attack(*ids.at(n)));
            n += 1;
        };
        attacks.span()
    }
    fn set_planned_attack(self: IWorldDispatcher, attack: PlannedAttack) {
        attack.set(self)
    }
    fn check_all_set(self: Span<PlannedAttack>) -> bool {
        let (mut n, len) = (0, self.len());
        let mut set = true;
        while n < len {
            if (*self.at(n).attack).is_zero() {
                set = false;
                break;
            }
            n += 1;
        };
        set
    }

    fn clear_planned_attack(self: IWorldDispatcher, id: felt252) {
        PlannedAttack { id, attack: 0, target: 0 }.set(self);
    }
    fn clear_planned_attacks(self: IWorldDispatcher, ids: Span<felt252>) {
        let (mut n, len) = (0, ids.len());
        while n < len {
            self.clear_planned_attack(*ids.at(n));
            n += 1;
        };
    }
}

