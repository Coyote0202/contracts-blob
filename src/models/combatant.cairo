use starknet::ContractAddress;
use blob_arena::{components::{stats::Stats}, utils};
use core::fmt::{Display, Formatter, Error, Debug};

#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct CombatantInfo {
    #[key]
    id: felt252,
    combat_id: felt252,
    player: ContractAddress,
    collection_address: ContractAddress,
    token_id: u256,
}

#[dojo::model]
#[derive(Drop, Serde, Copy, PartialEq)]
struct CombatantState {
    #[key]
    id: felt252,
    health: u8,
    stun_chance: u8,
    stats: Stats,
}


#[dojo::model]
#[derive(Drop, Serde, Copy)]
struct PlannedAttack {
    #[key]
    id: felt252,
    attack: felt252,
    target: felt252,
}

impl CombatantStateDisplayImpl of Display<CombatantState> {
    fn fmt(self: @CombatantState, ref f: Formatter) -> Result<(), Error> {
        write!(
            f,
            "id: {}, health: {}, stun_chance: {}, buffs: {:?}",
            self.id,
            self.health,
            self.stun_chance,
            *self.stats
        )
    }
}

impl CombatantStateDebugImpl = utils::TDebugImpl<CombatantState>;
