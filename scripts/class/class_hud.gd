extends Control
class_name HUD
@onready var player:Player = owner
@export var pause:Control


func _on_resume_pressed() -> void:
	pause.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
func _on_settings_pressed() -> void:
	pass # Replace with function body.
func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/system/main_menu.tscn")
