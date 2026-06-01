extends Control

@onready var history: ItemList = $Holder / HistoryHolder / History

func _ready() -> void :
	User.connect("ObjectAdded", Callable(self, "ObjAdded"))
	User.connect("ObjectRemoved", Callable(self, "ObjRemoved"))
	User.connect("ChangeBoard", Callable(self, "ChangedBoard"))
	Settings.emit_signal("SettingsChanged")

	var fileHistory = FileAccess.open("user://History.txt", FileAccess.READ)
	if fileHistory:
		var data = fileHistory.get_var(true)
		if !(data is Array):
			print("Error loading History File!")
			return
		User.RemovedHistory = data
		fileHistory.close()
		for i in User.RemovedHistory:
			if User.ProgressiveLoading:
				await get_tree().create_timer(User.LoadDur).timeout
			var img = get_node("Holder/ItemHolder/Items/" + i["Type"]).icon
			history.add_item("Removed: " + JSON.stringify(i, "\t", false, true), img)

	var fileSave = FileAccess.open("user://Save.txt", FileAccess.READ)
	if fileSave:
		var data = fileSave.get_var(true)
		if !(data is Array):
			print("Error loading Save File!")
			return
		User.StoredHistory = data
		fileSave.close()
		for i in User.StoredHistory:
			if User.ProgressiveLoading:
				await get_tree().create_timer(User.LoadDur).timeout
			if i["Type"] == "Board":
				User.Boards.merge({i["Board"] : i["Title"]}, true)
			initObj(i, false)

	var Settingsfile = FileAccess.open("user://Settings.txt", FileAccess.READ)
	if Settingsfile:
		var data = Settingsfile.get_var(true)
		if !(data is Array):
			print("Error loading Save File!")
			return
		Settingsfile.close()

		Settings.BackgroundCol = ValidateValue(data, 0)
		Settings.UpdatePath = ValidateValue(data, 1)

		Settings.emit_signal("SettingsChanged")

	User.StillLoading = false

func ValidateValue(array: Array, index):
	if array.size() >= index:
		return array[index]
	else:
		return null

func _physics_process(delta: float) -> void :
	if User.CurrentPage == "Settings":
		$Holder / ItemHolder.visible = false
	else:
		$Holder / ItemHolder.visible = true
	if Input.is_action_pressed("MultiSelect"):
		User.MultiSelecting = true
	if Input.is_action_just_released("MultiSelect"):
		User.MultiSelecting = false

	if Input.is_action_just_pressed("Undo") and history.item_count >= 1:
		Undo(User.RemovedHistory[User.RemovedHistory.size() - 1])
	if Input.is_action_just_pressed("Copy") and !User.InFocus:
		if User.SelectedObject:
			User.CopiedObject = get_node(User.SelectedObject).Data
	if Input.is_action_just_pressed("Paste") and !User.InFocus:
		if User.CopiedObject:
			var TempData = User.CopiedObject
			TempData["Pos"] = User.MousePos
			initObj(TempData, true)
		if User.MultiSelectedObjects.size() >= 1:
			for i in User.MultiSelectedObjects:
				initObj(get_node(i).Data, true)
		User.emit_signal("StoppedSelecting")
	if Input.is_action_just_pressed("Duplicate") and User.CopiedObject:
		initObj(User.CopiedObject, true)

	if Input.is_action_just_pressed("Delete"):
		if User.SelectedObject:
			User.emit_signal("ObjectRemoved", get_node(User.SelectedObject).Data)
			get_node(User.SelectedObject).queue_free()
			User.SelectedObject = null
		if User.MultiSelectedObjects.size() >= 1:
			for i in User.MultiSelectedObjects:
				User.emit_signal("ObjectRemoved", get_node(i).Data)
				get_node(i).queue_free()
			User.emit_signal("StoppedSelecting")
			User.MultiSelectedObjects = []

func Undo(data):
	initObj(data, true)

func initObj(data, emit = false):
	var obj = load("res://App/Assets/Scenes/" + data["Type"] + "/" + data["Type"] + ".tscn")
	System.AddObject(obj, false, data["ID"], data, emit)

func ObjAdded(data):

	if User.RemovedHistory.is_empty():
		return
	for i in User.RemovedHistory.size():
		if User.RemovedHistory[i] == data:
			User.RemovedHistory.remove_at(i)
			history.remove_item(i)

			break

func ObjRemoved(data):
	var img = get_node("Holder/ItemHolder/Items/" + data["Type"]).icon
	history.add_item("Removed: " + JSON.stringify(data, "\t", false, true), img)
	User.RemovedHistory.append(data)
	if User.StoredHistory.is_empty():
		return
	for i in User.StoredHistory.size():
		if User.StoredHistory[i] == data:
			User.StoredHistory.remove_at(i)

			break

func _on_history_item_activated(index: int) -> void :
	if history.get_selected_items().size() > 1:
		for i in history.get_selected_items():
			if history.get_item_text(i).begins_with("Removed: "):
				Undo(User.RemovedHistory[i])
	else:
		if history.get_item_text(index).begins_with("Removed: "):
			Undo(User.RemovedHistory[index])
		else:
			pass

func ChangedBoard(Board: String, Title: String):
	pass

func _exit_tree() -> void :
	User.emit_signal("SaveObjectData")

func _on_delete_pressed() -> void :
	history.clear()
	User.StoredHistory.clear()
	User.RemovedHistory.clear()
	User.Boards = {}
	System.SaveRemoveHistory()
	System.SaveStoreHistory()
	var boards = $"../../Boards"
	for i in boards.get_children():
		if !(i.name in ["Home", "Settings"]):
			i.queue_free()
	for i in boards.get_node("Home").get_children():
		if !(i.name in ["Button", "Preview"]):
			i.queue_free()
	User.emit_signal("ChangeBoard", "Home")


func _on_clear_pressed() -> void :
	history.clear()
	User.RemovedHistory.clear()
	System.SaveRemoveHistory()

func _on_search_text_submitted(new_text: String) -> void:
	User.emit_signal("Searched", new_text)
