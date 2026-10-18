extends Control

func Refresh():
	var dir = DirAccess.open("user://AutoSave")
	for i in $Scroll/Holder.get_children():
		i.queue_free()
	for i in dir.get_files():
		var butt = Button.new()
		butt.text = i
		butt.connect("pressed", Loadbackup.bind(i))
		$Scroll/Holder.add_child(butt)

func _ready() -> void:
	Refresh()

func Loadbackup(path : String):
	var file = FileAccess.open("user://AutoSave/" + path, FileAccess.READ)
	if file:
		var data = file.get_var(true)
		file.close()
		var Files = [System.SETTINGSFILE, System.SAVEFILE, System.HISTORYFILE]
		for i in Files.size():
			var fileSave = FileAccess.open(System.MAINDIR + Files[i] + System.EXTENSION, FileAccess.WRITE)
			if fileSave:
				fileSave.store_var(data.values()[i], true)
				fileSave.close()
		User.emit_signal("ApplySaveFile")

func _on_refresh_pressed() -> void:
	Refresh()
