extends Node

## Global references to clientside nodes for ease of access
var player:Player
var camera:Camera3D
var hud:HUD
var session:Session
var stage:Stage

## Multiplayer states
const STEAM_APP_ID = 480 # Change this to your assigned Steam appid. 480 (Spacewar) is only used for test purposes.
var STEAM_LOBBY_GAME_FILTER = ProjectSettings.get("application/config/name")
var host_settings = {
	&"lobby_name" : STEAM_LOBBY_GAME_FILTER + " Session",
	&"stage" : "dev_test",
	&"max_clients" : 2
}
enum SESSION_TYPE{HOST,CLIENT}
var session_type:int = 0
enum NETWORK_TYPE{ENET,STEAM}
var network_type:int = 0
var steam_lobby_id:int = 0
var direct_ip:String = ""

func create_warning(text:String,title:String):
	var new_popup:AcceptDialog = AcceptDialog.new()
	self.add_child(new_popup)
	new_popup.dialog_text = text
	new_popup.title = title
	new_popup.show()
	new_popup.position = (DisplayServer.window_get_size(0) / 2) - (new_popup.size / 2)
	new_popup.get_ok_button().pressed.connect(new_popup.queue_free)
func is_steam_running() -> bool:
	var initialize_response: Dictionary = Steam.steamInitEx( STEAM_APP_ID,true )
	return initialize_response["status"] == 0

func change_stage(scene_path:String) -> void:
	get_tree().set_pause(true)
	Loader.loading_layer.show()
	Loader.queue(scene_path,"PackedScene")
	Loader.loaded.connect(func(resource):Game.session.set_stage(resource),ConnectFlags.CONNECT_ONE_SHOT)
	await Loader.loaded
	get_tree().set_pause(false)
	Loader.loading_layer.hide()
	
