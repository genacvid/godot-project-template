extends ContainedWindow
class_name HostSession
@onready var session_name_edit: LineEdit = %SessionNameEdit
@onready var max_players_edit: SpinBox = %MaxPlayersEdit
@onready var stage_edit: MenuButton = %StageEdit

##
##	Start Session buttons
##

func _on_start_session_enet_pressed() -> void:
	Game.session_type = Game.SESSION_TYPE.HOST
	Game.network_type = Game.NETWORK_TYPE.ENET
	get_tree().change_scene_to_file("res://scenes/system/session.tscn")

func _on_start_session_steam_pressed() -> void:
	Game.session_type = Game.SESSION_TYPE.HOST
	Game.network_type = Game.NETWORK_TYPE.STEAM
	get_tree().change_scene_to_file("res://scenes/system/session.tscn")

##
##	Edit host settings
##

func _on_session_name_edit_text_submitted(new_text: String) -> void:
	Game.host_settings[&"lobby_name"] = new_text
func _on_max_players_edit_value_changed(value: float) -> void:
	Game.host_settings[&"max_clients"] = value
func _on_stage_edit_pressed() -> void:
	stage_edit.get_popup().id_pressed.connect(
		func(id):
		var stage_name = stage_edit.get_popup().get_item_text(id)
		stage_edit.text = "Stage: " + stage_name
		Game.host_settings[&"stage"] = stage_name,
		ConnectFlags.CONNECT_ONE_SHOT)


func _on_close_requested() -> void: self.hide()
