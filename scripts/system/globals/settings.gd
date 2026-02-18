extends Node

@export var video_settings = {
	&"resolution" : Vector2i(ProjectSettings.get("display/window/size/viewport_width"),ProjectSettings.get("display/window/size/viewport_height")),
	&"fullscreen" : false,
	&"borderless" : false,
	&"fit_to_screen" : false,
	&"texture_quality" : 1,
	&"animation_quality" : 1,
	&"model_quality" : 1,
}

## Enables the psx shader. Automatically applies the shader material
## at runtime, and modifies it according to settings.
## By default, this shader is not enabled, and will not load, regardless
## of model_quality setting.
@export var use_psx_shader:bool = false

@export var audio_settings = {
	&"master" : 1.0,
	&"sfx" : 1.0,
	&"bgm" : 1.0,
	&"menu" : 1.0
}
@export var gameplay_settings = {}
@export var control_settings = {"keybinds" : {}}
@onready var window: Window = $Window

var current_settings_file:ConfigFile = ConfigFile.new()
signal video_settings_changed
signal audio_settings_changed
signal gameplay_settings_changed
signal control_settings_changed
func _ready() -> void:
	restore_settings_file()
@export var bindable_actions:Array[String]
func write_settings_file() -> void:
	var keybinds:Dictionary = {}
	for action:String in InputMap.get_actions():
		if action in bindable_actions:
			var input_event_list:Array[InputEvent] = InputMap.action_get_events(action)
			keybinds[action] = input_event_list
	
	control_settings["keybinds"] = keybinds
	for key in video_settings.keys():
		current_settings_file.set_value("video",key,video_settings[key])
	for key in audio_settings.keys():
		current_settings_file.set_value("audio",key,audio_settings[key])
	for key in gameplay_settings.keys():
		current_settings_file.set_value("gameplay",key,gameplay_settings[key])
	for key in control_settings.keys():
		current_settings_file.set_value("controls",key,control_settings[key])
	current_settings_file.save("user://settings.cfg")
	print_rich(Debug.DEBUG_PRINT_SETTING + "Writting settings file")
func restore_settings_file() -> void:
	var directory = DirAccess.open("user://")
	if not directory.file_exists("settings.cfg"):
		print_rich(Debug.DEBUG_PRINT_SETTING + Debug.DEBUG_PRINT_WARNING + "Settings file does not exist! Writting...")
		write_settings_file()
	current_settings_file.load("user://settings.cfg")
	for key in video_settings.keys():
		video_settings[key] = current_settings_file.get_value("video",key,video_settings[key])
	for key in audio_settings.keys():
		audio_settings[key] = current_settings_file.get_value("audio",key,audio_settings[key])
	for key in gameplay_settings.keys():
		gameplay_settings[key] = current_settings_file.get_value("gameplay",key,gameplay_settings[key])
	for key in control_settings.keys():
		control_settings[key] = current_settings_file.get_value("controls",key,control_settings[key])
	fullscreen.set_pressed_no_signal(video_settings[&"fullscreen"])
	borderless.set_pressed_no_signal(video_settings[&"borderless"])
	fit_to_screen.set_pressed_no_signal(video_settings[&"fit_to_screen"])
	apply_video_settings()
	apply_audio_settings()
	print_rich(Debug.DEBUG_PRINT_SETTING + "Restoring settings file")

@onready var resolution: MenuButton = %Resolution
@onready var fullscreen: CheckButton = %Fullscreen
@onready var borderless: CheckButton = %Borderless
@onready var fit_to_screen: CheckButton = %FitToScreen
@onready var animation_quality: MenuButton = %AnimationQuality
@onready var texture_quality: MenuButton = %TextureQuality

func _on_resolution_pressed() -> void:
	resolution.get_popup().id_pressed.connect(func(id):
		var resolution_item = resolution.get_popup().get_item_text(id)
		var resolution_vector = Vector2i(int(resolution_item.rsplit("x")[0]),int(resolution_item.rsplit("x")[1]))
		video_settings[&"resolution"] = resolution_vector
		%Resolution.text = "Resolution: " + str(resolution_vector.x) + "x" + str(resolution_vector.y)
		apply_video_settings()
		)
func _on_texture_quality_pressed() -> void:
	texture_quality.get_popup().id_pressed.connect(func(id):
		video_settings[&"texture_quality"] = id
		match id:
			0: texture_quality.text = "Low"
			1: texture_quality.text = "High"
		apply_video_settings()
		)
func _on_animation_quality_pressed() -> void:
	animation_quality.get_popup().id_pressed.connect(func(id):
		video_settings[&"animation_quality"] = id
		match id:
			0: texture_quality.text = "Low"
			1: texture_quality.text = "High"
		apply_video_settings()
		)
func apply_video_settings():
	if video_settings[&"fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS,video_settings[&"borderless"])
	if video_settings[&"fit_to_screen"]:
		get_tree().get_root().set_content_scale_stretch(Window.CONTENT_SCALE_STRETCH_FRACTIONAL)
	else:
		get_tree().get_root().set_content_scale_stretch(Window.CONTENT_SCALE_STRETCH_INTEGER)
	get_window().size = video_settings[&"resolution"]
	video_settings_changed.emit()
func _on_window_close_requested() -> void:
	write_settings_file()
	window.hide()


func _on_fullscreen_pressed() -> void:
	video_settings[&"fullscreen"] = %Fullscreen.button_pressed
func _on_borderless_pressed() -> void:
	video_settings[&"borderless"] = %Fullscreen.button_pressed
func _on_fit_to_screen_pressed() -> void:
	video_settings[&"fit_to_screen"] = %Fullscreen.button_pressed

enum AUDIO_BUS{MASTER,SFX,MUSIC,MENU}

func apply_audio_settings():
	_on_menu_slider_value_changed(audio_settings[&"menu"])
	_on_sound_slider_value_changed(audio_settings[&"sfx"])
	_on_music_slider_value_changed(audio_settings[&"bgm"])

func _on_sound_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AUDIO_BUS.SFX, linear_to_db(audio_settings[&"sfx"]/100.0))
func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AUDIO_BUS.SFX, linear_to_db(audio_settings[&"bgm"]/100.0))
func _on_menu_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AUDIO_BUS.SFX, linear_to_db(audio_settings[&"menu"]/100.0))
