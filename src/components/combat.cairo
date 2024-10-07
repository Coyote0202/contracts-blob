use core::{
    fmt::{Display, Formatter, Error}, hash::{HashStateTrait, HashStateExTrait, Hash},
    poseidon::{poseidon_hash_span, PoseidonTrait, HashState}
};
use starknet::{ContractAddress, get_block_number};
use dojo::{world::{IWorldDispatcher, IWorldDispatcherTrait}, model::Model};
use blob_arena::{
    components::{utils::{ABT, Status, Winner}, commitment::Commitment},
    models::{
        SaltsModel, Phase, AttackHit, AttackEffect, CombatState, CombatStateStore, PlannedAttack,
        PlannedAttackStore, CombatantState
    }
};
type Salts = Array<felt252>;

#[generate_trait]
impl SaltsImpl of SaltsTrait {
    fn get_salts_model(self: IWorldDispatcher, id: u128) -> SaltsModel {
        get!(self, id, SaltsModel)
    }

    fn set_salts(self: IWorldDispatcher, id: u128, salts: Salts) {
        set!(self, (SaltsModel { id, salts: Option::Some(salts) },));
    }

    fn append_salt(self: IWorldDispatcher, id: u128, salt: felt252) {
        let mut salts = self.get_salts(id);
        salts.append(salt);
        self.set_salts(id, salts);
    }

    fn reset_salts(self: IWorldDispatcher, id: u128) {
        set!(self, (SaltsModel { id, salts: Option::None(()) }));
    }
    fn get_salts(self: IWorldDispatcher, id: u128) -> Salts {
        match self.get_salts_model(id).salts {
            Option::Some(salts) => salts,
            Option::None => ArrayTrait::new()
        }
    }


    fn get_salts_hash(self: IWorldDispatcher, id: u128) -> felt252 {
        poseidon_hash_span(self.get_salts(id).span())
    }

    fn get_salts_hash_state(self: IWorldDispatcher, id: u128) -> HashState {
        let mut salts = self.get_salts(id);
        let mut hash_state = PoseidonTrait::new();
        loop {
            match salts.pop_front() {
                Option::Some(salt) => { hash_state.update(salt); },
                Option::None => { break; },
            }
        };
        // let (mut n, len) = (0, salts.len());

        // while n < len {
        //     hash_state.update(*salts.at(n));
        //     n += 1;
        // };
        hash_state
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
    fn get_combat_state(self: @IWorldDispatcher, id: u128) -> CombatState {
        CombatStateStore::get(*self, id)
    }
    fn new_combat_state(self: IWorldDispatcher, id: u128) {
        CombatState { id, phase: Phase::Commit, round: 1, block_number: get_block_number() }
            .set(self)
    }
    fn get_combat_phase(self: @IWorldDispatcher, id: u128) -> Phase {
        self.get_combat_state(id).phase
    }
    fn get_running_combat_state(self: @IWorldDispatcher, id: u128) -> CombatState {
        let state = self.get_combat_state(id);
        state.phase.assert_running();
        state
    }
    fn next_round(self: IWorldDispatcher, mut state: CombatState, combatants: Span<u128>) {
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
    fn get_combatants_mortality(mut self: Array<CombatantState>) -> (Array<u128>, Array<u128>) {
        let mut alive = ArrayTrait::<u128>::new();
        let mut dead = ArrayTrait::<u128>::new();
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
    fn end_combat(self: IWorldDispatcher, mut state: CombatState, winner: u128) {
        state.phase = Phase::Ended(winner);
        state.set(self);
    }
}


#[generate_trait]
impl PlannedAttackImpl of PlannedAttackTrait {
    fn get_planned_attack(self: @IWorldDispatcher, id: u128) -> PlannedAttack {
        PlannedAttackStore::get(*self, id)
    }
    fn get_planned_attacks(self: @IWorldDispatcher, ids: Span<u128>) -> Span<PlannedAttack> {
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

    fn clear_planned_attack(self: IWorldDispatcher, id: u128) {
        PlannedAttack { id, attack: 0, target: 0 }.set(self);
    }
    fn clear_planned_attacks(self: IWorldDispatcher, ids: Span<u128>) {
        let (mut n, len) = (0, ids.len());
        while n < len {
            self.clear_planned_attack(*ids.at(n));
            n += 1;
        };
    }
}

