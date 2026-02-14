extends Window
class_name ContainedWindow

func _process(delta: float) -> void:
	position.x = clamp(position.x,0,DisplayServer.window_get_size(0).x - size.x)
	position.y = clamp(position.y,16,DisplayServer.window_get_size(0).y - size.y)
