use starknet::{ContractAddress, get_caller_address};
use dojo::world::{IWorldDispatcherTrait};
use blob_arena::{
    components::{blobert::BlobertTrait, lobby::{Lobby, LobbyPlayer}, world::{World}},
    systems::{blobert::BlobertWorldTrait}
};

#[generate_trait]
impl LobbyImpl of LobbyTrait {
    fn get_lobby(self: World, id: u128) -> Lobby {
        get!(self, id, Lobby)
    }

    fn get_lobby_player(self: World, player: ContractAddress) -> LobbyPlayer {
        get!(self, player, LobbyPlayer)
    }

    fn get_running_lobby(self: World, id: u128) -> Lobby {
        let lobby = self.get_lobby(id);
        assert(lobby.running, 'Lobby not running');
        lobby
    }

    fn get_lobby_caller(self: World) -> LobbyPlayer {
        self.get_lobby_player(get_caller_address())
    }

    fn create_lobby(self: World, blobert_id: u128) -> u128 {
        let id: u128 = self.uuid().into();
        let caller = get_caller_address();
        self.add_to_lobby(caller, id, blobert_id);
        let lobby = Lobby { id, owner: caller, running: true };

        set!(self, (lobby,));
        id
    }

    fn leave_lobby(self: World) {
        let mut player = self.get_lobby_caller();
        assert(player.joined, 'Player not in lobby');
        let lobby = self.get_lobby(player.lobby_id);
        assert(player.address != lobby.owner, 'Cannot leave own lobby');
        player.lobby_id = 0;
        player.joined = false;
        set!(self, (player,));
    }

    fn close_lobby(self: World) {
        let mut player = self.get_lobby_caller();
        let mut lobby = self.get_lobby(player.lobby_id);
        assert(lobby.owner == player.address, 'Not lobby owner');
        player.lobby_id = 0;
        player.joined = false;
        lobby.running = false;

        set!(self, (player, lobby));
    }

    fn join_lobby(self: World, lobby_id: u128, blobert_id: u128) {
        self.get_running_lobby(lobby_id);
        self.add_to_lobby(get_caller_address(), lobby_id, blobert_id);
    }
    fn add_to_lobby(self: World, player: ContractAddress, lobby_id: u128, blobert_id: u128) {
        let player = self.get_lobby_player(player);
        if player.joined {
            let lobby = self.get_lobby(player.lobby_id);
            assert(!lobby.running, 'Player already in lobby');
        }
        let blobert = self.get_blobert(blobert_id);
        blobert.assert_owner(player.address);
        let lobby_player = LobbyPlayer {
            address: player.address, lobby_id, blobert_id, wins: 0, joined: true
        };
        set!(self, (lobby_player,));
    }
}
