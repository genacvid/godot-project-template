extends Control
class_name MainMenu
@onready var session_browser: SessionBrowser = $SessionBrowser

@onready var host_session: HostSession = $HostSession
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
func _on_start_session_pressed() -> void:
	session_browser.hide()
	host_session.show()
func _on_join_session_pressed() -> void:
	host_session.hide()
	session_browser.show()
func _on_settings_pressed() -> void:
	Settings.window.show()
