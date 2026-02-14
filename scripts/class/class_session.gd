@tool
extends Node
## Facilitates multiplayer connections and synchronization
class_name Session

signal client_connected(peer_id, client_info)
signal client_disconnected(peer_id)
signal server_disconnected
signal client_ready

@export_tool_button("Populate Stages") var populate_stages_button:Callable = populate_stages
@onready var spawner:MultiplayerSpawner = $MultiplayerSpawner
const DEFAULT_PORT:int = 4565
const LOCALHOST:String = "127.0.0.1"
const HOST_ID = 1
const PLAYER = preload("uid://dkajcrr1254sh")
const TEST_STAGE = "res://scenes/stage/test.tscn"

## different multiplayer peers to handle client connections
var enet_peer:ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var steam_peer:SteamMultiplayerPeer = SteamMultiplayerPeer.new()

## Data shared across all clients.
## Key is client id. Value is a Dictionary containing their local client info.
var shared_client_info:Dictionary = {}
## Data sent to other clients.
## Dictionary contains custom info.
var local_client_info:Dictionary = {}
## Maximum amount of clients connected to the host.
var clients_loaded:int = 0

func populate_stages():
	var directory = DirAccess.open("res://scenes/stage/")
	for file in directory.get_files(): spawner.add_spawnable_scene(file)

func _ready() -> void:
	Game.session = self
	## Functions ran on host when a client connects
	multiplayer.peer_connected.connect(on_client_connect)
	multiplayer.peer_disconnected.connect(on_client_disconnect)
	
	## Functions ran on client when they connect to a host
	multiplayer.connected_to_server.connect(on_connect_to_host)
	multiplayer.server_disconnected.connect(on_disconnect_from_host)

	## Functions ran when a client fails to connect to a host
	multiplayer.connection_failed.connect(on_connect_fail)

	## Steam lobby functions go here
	Steam.lobby_joined.connect(steam_lobby_joined)
	Steam.lobby_created.connect(steam_lobby_created)
	Steam.lobby_kicked.connect(kicked_from_steam_lobby)
	
	## Initalize client info
	update_client_info()

	## Check session type and set up client/host
	match Game.session_type:
		Game.SESSION_TYPE.HOST:
			match Game.network_type:
				Game.NETWORK_TYPE.ENET: start_as_enet_host()
				Game.NETWORK_TYPE.STEAM: start_as_steam_host()
		Game.SESSION_TYPE.CLIENT:
			match Game.network_type:
				Game.NETWORK_TYPE.ENET: start_as_enet_client()
				Game.NETWORK_TYPE.STEAM: Steam.joinLobby(Game.steam_lobby_id)

##	ENet Networking
##	Only ENetMultiplayerPeer can call these functions.

func start_as_enet_host():
	enet_peer.create_server(DEFAULT_PORT,Game.host_settings[&"max_clients"])
	multiplayer.multiplayer_peer = enet_peer
	shared_client_info[HOST_ID] = local_client_info
	print_rich(Debug.DEBUG_PRINT_SESSION_HOST + "Hosting ENet session")
	setup_host_scene()

func start_as_enet_client():
	enet_peer.create_client(Game.direct_ip,DEFAULT_PORT)
	multiplayer.multiplayer_peer = enet_peer
	print_rich(Debug.DEBUG_PRINT_SESSION_CLIENT + "Connecting to ENet session")
	## After connection to host is established, MultiplayerPeer should start populating Session with nodes from the host

##	Steam Networking
##	Only SteamMultiplayerPeer can call these functions.

func steam_lobby_created(_connect: int, _lobby_id: int):
	if _connect == 1:
		Game.steam_lobby_id = _lobby_id
		Steam.setLobbyData(_lobby_id,&"game",Game.STEAM_LOBBY_GAME_FILTER)
		Steam.setLobbyData(_lobby_id,&"lobby_name",str(Game.host_settings[&"lobby_name"]))
		Steam.setLobbyData(_lobby_id,&"lobby_max_size",str(Game.host_settings[&"max_clients"]))

func steam_lobby_joined(lobby: int, permissions: int, locked: bool, response: int):
	if response == 1:
		var owner_id = Steam.getLobbyOwner(lobby)
		if owner_id != Steam.getSteamID():
			start_as_steam_client(owner_id)
	else:
		var fail_reason: String
		match response:
			Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST: fail_reason = "This session no longer exists."
			Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED: fail_reason = "You don't have permission to join this session."
			Steam.CHAT_ROOM_ENTER_RESPONSE_FULL: fail_reason = "The session is now full."
			Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR: fail_reason = "An unknown error has occured."
			Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED: fail_reason = "You are banned from this session."
			Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED: fail_reason = "You cannot join due to having a limited account."
			Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED: fail_reason = "This session is locked or disabled."
			Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN: fail_reason = "This session is community locked."
			Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU: fail_reason = "A user in the session has blocked you from joining."
			Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER: fail_reason = "A user you have blocked is in the session."
		## Run post error logic here
		OS.alert(fail_reason,"Connection Error")

func start_as_steam_host():
	if not Game.is_steam_running():
		print_rich(Debug.DEBUG_PRINT_ERROR + "Steam is not running!")
		get_tree().change_scene_to_file("res://scenes/system/main_menu.tscn")
		return
	steam_peer.create_host(0)
	multiplayer.multiplayer_peer = steam_peer
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC,Game.host_settings[&"max_clients"])
	print_rich(Debug.DEBUG_PRINT_SESSION_HOST + "Hosting Steam session")
	setup_host_scene()

func start_as_steam_client(id:int):
	if not Game.is_steam_running(): print_rich(Debug.DEBUG_PRINT_ERROR + "Steam is not running!")
	steam_peer.create_client(id,0)
	multiplayer.multiplayer_peer = steam_peer
	print_rich(Debug.DEBUG_PRINT_SESSION_CLIENT + "Connecting to Steam session")
	## After connection to host is established, MultiplayerPeer should start populating Session with nodes from the host

func kicked_from_steam_lobby(lobby_id: int, admin_id: int, due_to_disconnect: int):
	pass

##	MultiplayerPeer handling
##	All multiplayer peers will call these functions

## Ran on host when a client connects to the session
func on_client_connect(id:int):
	if id != HOST_ID:
		add_player(id)
	register_client_info.rpc_id(id,local_client_info)
	await client_connected
	## Do join messages here

## Ran on host when a client disconnects from the session
func on_client_disconnect(id:int):
	if id == HOST_ID:
		## Server has shutdown, disconnect all clients here
		Game.create_warning("Host disconnected.","Session ended")
		get_tree().change_scene_to_file("res://scenes/system/main_menu.tscn")
	shared_client_info.erase(id)
	client_disconnected.emit(id)
	remove_player(id)
## Ran on clients when connecting to a session
func on_connect_to_host():
	var peer_id = multiplayer.get_unique_id()
	shared_client_info[peer_id] = local_client_info
	client_connected.emit(peer_id,local_client_info)
	if peer_id != HOST_ID:
		## Do join messages here
		pass

## Ran on clients when they leave the session
func on_disconnect_from_host(id:int):
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	shared_client_info.clear()
	server_disconnected.emit()

## Only ran on clients when MultiplayerPeer fails to connect
func on_connect_fail():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

func _exit_tree() -> void:
	print_rich(Debug.DEBUG_PRINT_SESSION_HOST + "Ending session.")
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

##	Info registration
##	Used for synchronizing data between clients

func update_client_info():
	register_client_info.rpc(local_client_info)

@rpc("any_peer", "reliable")
## Only players with the correct ID can write to their respective shared data entry using rpc_id
func register_client_info(client_info:Dictionary):
	var new_client_id = multiplayer.get_remote_sender_id()
	shared_client_info[new_client_id] = client_info
	client_connected.emit(new_client_id, client_info)

##	Session instantiations for host
##	These do NOT get ran on clients. A client's MultiplayerPeer will automatically instantiate whatever is in the host's session upon connection.
func setup_host_scene():
	Game.change_stage("res://scenes/stage/" + Game.host_settings[&"stage"] + ".tscn")
	await Loader.loaded
	add_player(HOST_ID)

## Adds a player entity to the scene
func add_player(peer_id):
	var new_player = PLAYER.instantiate()
	new_player.name = str(peer_id)
	add_child(new_player)

## Replace current stage
func set_stage(scene:PackedScene):
	if is_instance_valid(Game.stage): Game.stage.queue_free()
	var new_stage:Stage = scene.instantiate()
	add_child(new_stage,true)
	Game.stage = new_stage

## Search for a player node by id and then remove them. Ran on host and all clients.
func remove_player(id:int):
	print_rich(Debug.DEBUG_PRINT_SESSION_CLIENT + "Client " + str(id) + " disconnected")
	var player_ref = get_node_or_null(str(id))
	if is_instance_valid(player_ref):
		player_ref.queue_free()
