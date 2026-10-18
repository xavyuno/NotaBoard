extends Control

@onready var history: ItemList = $Holder/History / HistoryHolder / History

func _ready() -> void :
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))
	Init()
	System.SwitchBoard(Settings.Data["CurrentPage"], Settings.Data["PageTitle"])
	User.connect("DeleteAll", DeleteAll)

func SettingsChanged():
	$Holder/History.visible = Settings.Data["HistoryCollapsed"]

func DeleteAll():
	Settings.Data["TotalItems"] = 0
	history.clear()
	User.StoredHistory.clear()
	User.History.clear()
	User.Boards = {}
	System.SaveRemoveHistory()
	System.SaveStoreHistory()
	var boards = $"../../Boards"
	for i in boards.get_children():
		if !i.is_in_group("Protect"):
			i.queue_free()
	for i in boards.get_node("Home").get_children():
		if !i.is_in_group("Protect"):
			i.queue_free()
	User.emit_signal("ChangeBoard", "Home", "Home", "", Settings.Data["CamPosHome"], Settings.Data["CamZoomHome"])
	$Holder/History/DeleteAll.visible = false

func Init():
	get_parent().visible = true
	User.connect("ObjectAdded", Callable(self, "ObjAdded"))
	User.connect("ObjectRemoved", Callable(self, "ObjRemoved"))
	User.connect("ChangeBoard", Callable(self, "ChangedBoard"))
	User.connect("ApplySaveFile", Callable(self, "ApplySaveFile"))
	User.connect("ItemChanged", Callable(self, "ItemChanged"))

	var Settingsfile = System.LoadFile(System.MAINDIR + System.SETTINGSFILE + System.EXTENSION)
	if Settingsfile:
		var data = Settingsfile
		if !(data is Dictionary):
			print("Error loading settings File!")
			System.BackupAll()
		else:
			Settings.Data.merge(data, true)
	Settings.emit_signal("SettingsChanged")
	User.emit_signal("ChangedOptionsBar")

	var fileHistory = System.LoadFile(System.MAINDIR + System.HISTORYFILE + System.EXTENSION)
	if fileHistory:
		var data = fileHistory
		if !(data is Array):
			print("Error loading History File!")
			System.BackupAll()
		else:
			User.History = data
			for i in User.History:
				if i["Data"]["Type"] != "Line":
					if Settings.Data["ProgressiveLoading"]:
						await get_tree().create_timer(User.LoadDur).timeout
					var img = get_node("Holder/ItemHolder/Items/" + i["Data"]["Type"]).icon
					history.add_item(i["Action"] + " Item " + i["ID"] + ":" + JSON.stringify(i["Data"], "\t", false, true), img)

	var fileSave = System.LoadFile(System.MAINDIR + System.SAVEFILE + System.EXTENSION)
	if fileSave:
		var data = fileSave
		if !(data is Array):
			print("Error loading Save File!")
			System.BackupAll()
		else :
			User.StoredHistory = data
			for i in User.StoredHistory:
				if Settings.Data["ProgressiveLoading"]:
					await get_tree().create_timer(User.LoadDur).timeout
				if i["Type"] == "Board":
					User.Boards.merge({
						i["Board"] : {
							"Title" : System.GetOrNull(i, "Title", ""),
							"ID" : System.GetOrNull(i, "ID", ""),
							 "CamPos" : System.GetOrNull(i, "CamPos", Vector2(640, 352)),
							 "CamZoom" : System.GetOrNull(i, "CamZoom", Vector2(1, 1), TYPE_VECTOR2)
							}}, true)
				initObj(i, false)

	User.StillLoading = false
	if Settings.Data["TotalBoards"] <= 0:
		await get_tree().create_timer(6).timeout
		for i in $"../../Boards".get_children():
			if int(i.name) > Settings.Data["TotalBoards"]:
				Settings.Data["TotalBoards"] = int(i.name) + 1
	Customization.emit_signal("ApplyCustomization")
	Customization.emit_signal("Reload")

func ApplySaveFile():
	User.StillLoading = true

	var boards = $"../../Boards"
	for i in boards.get_children():
		if !i.is_in_group("Protect"):
			i.queue_free()
	for i in boards.get_node("Home").get_children():
		if !i.is_in_group("Protect"):
			i.queue_free()

	Init()

func _process(_delta: float) -> void :
	if get_global_mouse_position().x <= 160:
		User.MouseInCanvas = true
	else :
		User.MouseInCanvas = false
	
	if Input.is_action_pressed("MultiSelect"):
		User.MultiSelecting = true
	if Input.is_action_just_released("MultiSelect"):
		User.MultiSelecting = false

	if Input.is_action_just_pressed("Undo") and history.item_count >= 1 and !User.InFocus:
		LastAction(history.item_count - 1)
	if Input.is_action_just_pressed("Copy") and !User.InFocus:
		if User.SelectedObject:
			User.CopiedObject = get_node(User.SelectedObject).Data
		if User.MultiSelectedObjects.size() >= 1:
			User.MultiCopiedObjects = []
			for i in User.MultiSelectedObjects:
				User.MultiCopiedObjects.append(get_node(i).Data)
			User.MultiSelectedObjects = []
	if Input.is_action_just_pressed("Cut") and !User.InFocus:
		if User.SelectedObject:
			User.CopiedObject = get_node(User.SelectedObject).Data
			get_node(User.SelectedObject).queue_free()
		if User.MultiSelectedObjects.size() >= 1:
			User.MultiCopiedObjects = []
			for i in User.MultiSelectedObjects:
				User.MultiCopiedObjects.append(get_node(i).Data)
			for i in User.MultiSelectedObjects:
				get_node(i).queue_free()
			User.MultiSelectedObjects = []
		User.emit_signal("ItemFocusLost")
	if Input.is_action_just_pressed("Paste") and !User.InFocus and !get_node("../../Boards/" + Settings.Data["CurrentPage"]).is_in_group("NoCanvas"):
		if User.CopiedObject:
			var TempData = User.CopiedObject
			TempData["Pos"] = User.MousePos
			TempData["ID"] = Settings.Data["CurrentPage"]
			initObj(TempData, true)
		elif User.MultiSelectedObjects.size() >= 1:
			for i in User.MultiSelectedObjects:
				initObj(get_node(i).Data, true)
		elif User.MultiCopiedObjects.size() >= 1:
			for i in User.MultiCopiedObjects:
				initObj(i, true)
		else:
			if DisplayServer.clipboard_has_image():
				var obj = preload("res://App/Assets/Scenes/File/File.tscn").instantiate()
				var saveImg := DisplayServer.clipboard_get_image()
				DirAccess.make_dir_absolute("user://PastedImages")
				var files = DirAccess.get_files_at("user://PastedImages")
				var filepath
				if files.size() > 0:
					filepath = "user://PastedImages/" + str( int(files.size()) + 1 ) + ".png"
				else :
					filepath = "user://PastedImages/1.png"
				saveImg.save_png(filepath)
				obj.Data["Dir"] = filepath
				System.AddObject(obj)
			else:
				var cb := DisplayServer.clipboard_get()
				if cb.begins_with("Https://") or cb.begins_with("https://") or cb.begins_with("www.") or cb.ends_with(".com") or cb.ends_with(".na"):
					var obj = preload("res://App/Assets/Scenes/Link/Link.tscn").instantiate()
					obj.Data["Link"] = cb
					System.AddObject(obj)
				else:
					if User.CopiedData["Data"]:
						var obj = preload("res://App/Assets/Scenes/File/File.tscn").instantiate()
						obj.Data["CachedImage"] = User.CopiedData["Data"]
						System.AddObject(obj)
						obj.size = User.CopiedData["Size"]
		User.emit_signal("StoppedSelecting")
	if Input.is_action_just_pressed("Duplicate") and User.CopiedObject:
		initObj(User.CopiedObject, true)

func Undo(data, emit):
	initObj(data, emit)

func initObj(data, updateHistory = true):
	var obj = load("res://App/Assets/Scenes/" + data["Type"] + "/" + data["Type"] + ".tscn")
	System.AddObject(obj, false, data["ID"], data, updateHistory)

func ObjAdded(data, updateHistory : bool):
	if updateHistory:
		var img = get_node("Holder/ItemHolder/Items/" + data["Type"]).icon
		history.add_item("Added Item " + str(Settings.Data["TotalItems"] + 1) + ":" + JSON.stringify(data, "\t", false, true), img)
		data["ItemID"] = str(Settings.Data["TotalItems"] + 1)
		User.History.append(
			{
				"ID" : data["ItemID"],
				"Action" : "Added",
				"Data" : data
			}
		)

func ObjRemoved(data):
	var img = get_node("Holder/ItemHolder/Items/" + data["Type"]).icon
	history.add_item("Removed Item " + data["ItemID"] + ":" + JSON.stringify(data, "\t", false, true), img)
	User.History.append({
			"ID" : data["ItemID"],
			"Action" : "Removed",
			"Data" : data
		}
	)

func ItemChanged(data):
	var img = get_node("Holder/ItemHolder/Items/" + data["Type"]).icon
	history.add_item("Changed Item " + data["ItemID"] + ":" + JSON.stringify(data, "\t", false, true), img)
	User.History.append({
			"ID" : data["ItemID"],
			"Action" : "Changed",
			"Data" : data
		}
	)

func _on_history_item_activated(_index: int) -> void :
	for i in history.get_selected_items():
		LastAction(i)

func LastAction(index):
	var action := history.get_item_text(index)
	if action.begins_with("Removed"):
		Undo(User.History[index]["Data"], false)
	elif action.begins_with("Added"):
		User.emit_signal("DeleteItem", User.History[index]["Data"]["ItemID"])
	elif action.begins_with("Changed"):
		User.emit_signal("ApplyItemChange", User.History[index]["Data"])
	User.History.remove_at(index)
	history.remove_item(index)

func ChangedBoard(Board: String, _Title: String, _ID = "", _CamPos = Vector2(640, 352), _CamZoom = 1):
	if get_node("../../Boards/" + Board).is_in_group("NoCanvas"):
		visible = false
	else:
		visible = Settings.Data["ToolbarVisible"]
	
	User.emit_signal("ItemFocusLost")

func _exit_tree() -> void :
	User.emit_signal("SaveObjectData")


func _on_clear_pressed() -> void :
	history.clear()
	User.History.clear()
	System.SaveRemoveHistory()


func _on_history_item_clicked(index: int, _at_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index == 2:
		$Holder/History/HistoryHolder/History.remove_item(index)
		User.History.erase(User.History[index])
		System.SaveRemoveHistory()


func _on_search_text_changed(new_text: String) -> void:
	if new_text == "":
		User.emit_signal("Searched", "")

func _on_search_text_submitted(new_text: String) -> void:
	User.emit_signal("Searched", new_text)

func _on_title_pressed() -> void:
	$Holder/History.visible = !$Holder/History.visible
	Settings.Data["HistoryCollapsed"] = $Holder/History.visible
