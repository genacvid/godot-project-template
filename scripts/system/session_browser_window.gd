extends ContainedWindow
class_name SessionBrowser
@onready var status_label: Label = %SteamStatusLabel
@onready var lobby_container: VBoxContainer = %LobbyContainer
@onready var direct_ip_address: LineEdit = %DirectIPAddress

func _ready() -> void:
	Steam.lobby_match_list.connect(_on_lobby_match_list)

func _on_close_requested() -> void: self.hide()

func _on_visibility_changed() -> void:
	if visible:
		if not Game.is_steam_running():
			status_label.text = "Steam is not running."
			return
		status_label.text = "Searching for sessions..."
		Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
		Steam.addRequestLobbyListStringFilter("game",Game.STEAM_LOBBY_GAME_FILTER,Steam.LOBBY_COMPARISON_EQUAL)
		Steam.requestLobbyList()

func _on_lobby_match_list(lobby_list:Array):
	status_label.text = ""
	for node in lobby_container.get_children():
		if node is Button:
			node.queue_free()
	if lobby_list.is_empty():
		status_label.text = "No sessions were found."
	for lobby in lobby_list:
		## Make buttons that set the steam lobby id, and connect as a client!
		var lobby_name = Steam.getLobbyData(lobby,"lobby_name")
		var lobby_max_size = Steam.getLobbyData(lobby,"lobby_max_size")
		var lobby_current_size = Steam.getNumLobbyMembers(lobby)
		var new_lobby_button = Button.new()
		lobby_container.add_child(new_lobby_button)
		new_lobby_button.text = lobby_name + " - Players: " + str(lobby_current_size) + "/" + str(lobby_max_size)
		new_lobby_button.pressed.connect(_on_lobby_button_pressed.bind(lobby))

func _on_lobby_button_pressed(lobby_id:int):
	Game.steam_lobby_id = lobby_id
	Game.network_type = Game.NETWORK_TYPE.STEAM
	Game.session_type = Game.SESSION_TYPE.CLIENT
	get_tree().change_scene_to_file("res://scenes/system/session.tscn")


func _on_direct_join_button_pressed() -> void:
	if direct_ip_address.text.is_valid_ip_address():
		Game.direct_ip = direct_ip_address.text
		Game.network_type = Game.NETWORK_TYPE.ENET
		Game.session_type = Game.SESSION_TYPE.CLIENT
		get_tree().change_scene_to_file("res://scenes/system/session.tscn")
		
