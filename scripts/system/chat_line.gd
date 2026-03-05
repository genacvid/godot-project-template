extends LineEdit
class_name ChatLine


func _on_text_submitted(new_text: String) -> void:
	if new_text.is_empty(): return
	Game.session.send_chat_message.rpc(str(multiplayer.get_unique_id()) + ": " + new_text)
	text = ""
	release_focus()

func _on_focus_entered() -> void:
	Game.chatting = true
	self.show()
func _on_focus_exited() -> void:
	Game.chatting = false
	self.hide()
