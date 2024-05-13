use starknet::{ContractAddress};

#[derive(Model, Copy, Drop, Print, Serde)]
struct Lobby {
    #[key]
    id: u128,
    owner: ContractAddress,
    running: bool,
}

#[derive(Model, Copy, Drop, Print, Serde)]
struct LobbyPlayer {
    #[key]
    address: ContractAddress,
    lobby_id: u128,
    blobert_id: u128,
    wins: u128,
    joined: bool,
}
