@tool
extends Area3D
class_name Water

func _func_godot_build_complete() -> void:
	body_entered.connect(_on_body_entered,CONNECT_PERSIST)
	body_exited.connect(_on_body_exited,CONNECT_PERSIST)

func _on_body_entered(body: Node3D) -> void:
	if body is Entity:
		body.move.in_water = true
func _on_body_exited(body: Node3D) -> void:
	if body is Entity:
		body.move.in_water = false
