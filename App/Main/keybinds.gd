extends Panel

var ChangingKeybind = false

func _on_keybind_change_pressed() -> void:
	await get_tree().create_timer(0.5).timeout
	ChangingKeybind = true

func _input(event: InputEvent) -> void:
	if ChangingKeybind and event is InputEventKey:
		ChangingKeybind = false
		InputMap.action_add_event("Bold", event)

func _ready() -> void:
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))


func SettingsChanged():
	for i in$ScrollHolder/Holder.get_children():
		i.queue_free()
	for i in Settings.Data["SavedKeybinds"].keys():
		var KBE = preload("res://App/Main/keybind_event.tscn").instantiate()
		KBE.Event = i
		$ScrollHolder/Holder.add_child(KBE)
