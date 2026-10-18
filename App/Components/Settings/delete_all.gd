extends Panel

func _on_delete_pressed() -> void:
	$DeleteAll.visible = !$DeleteAll.visible

func _on_yes_pressed() -> void:
	User.emit_signal("DeleteAll")

func _on_no_pressed() -> void:
	$DeleteAll.visible = false
