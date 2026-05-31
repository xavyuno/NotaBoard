extends Control

func _physics_process(delta: float) -> void :
	if get_global_mouse_position().x > get_parent().get_node("Nodes").position.x:
		User.MouseInCanvas = true
	else:
		User.MouseInCanvas = false

func _on_close_pressed() -> void :
	get_parent().get_node("Nodes").visible = !get_parent().get_node("Nodes").visible

func _on_settings_pressed() -> void :
	if User.CurrentPage != "Settings":
		User.emit_signal("ChangeBoard", "Settings", "Settings")
	else:
		User.emit_signal("ChangeBoard", User.PreviousPage, User.PreviousTitle)

func _on_preview_pressed() -> void:
	User.PreviewingNotes = !User.PreviewingNotes
	User.emit_signal("PreviewNotes")
