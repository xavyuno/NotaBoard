extends Node

func SaveAll():
	if User.TestingMode:
		return
	SaveStoreHistory()
	SaveRemoveHistory()
	SaveSettings()

func GetAPI(Index) -> String:
	var file = FileAccess.open("res://.API" ,FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	return data[Index]

func SaveStoreHistory():
	var fileSave = FileAccess.open("user://Save.txt", FileAccess.WRITE)
	fileSave.store_var(User.StoredHistory, true)
	fileSave.close()

func SaveSettings():
	var fileSave = FileAccess.open("user://Settings.txt", FileAccess.WRITE)
	fileSave.store_var(Settings.GetSettings(), true)
	fileSave.close()

func CreateRectangle(p1: Vector2, p2: Vector2):
	var TopRight = Vector2(p2.x, p1.y)
	var BottomLeft = Vector2(p1.x, p2.y)
	var Vertices = PackedVector2Array()
	Vertices.append(p1)
	Vertices.append(TopRight)
	Vertices.append(p2)
	Vertices.append(BottomLeft) 
	Vertices.append(p1)
	return Vertices

func SaveRemoveHistory():
	var file = FileAccess.open("user://History.txt", FileAccess.WRITE)
	file.store_var(User.RemovedHistory, true)
	file.close()

func AddObject(item, atMouse = true, parent = null, extraData = {}, emit = true):
	var obj
	if item is PackedScene:
		obj = item.instantiate()
	elif item is Object:
		obj = item
	else:
		obj = load(item).instantiate()
	if extraData.has("Board"):
		obj.Data["Board"] = extraData["Board"]
	if !extraData.is_empty():
		obj.Data = extraData
	if parent != null:
		if get_tree().current_scene.has_node("Boards/" + parent) != null:
			var board = preload("res://App/Assets/Scenes/NewBoard/NewBoard.tscn").instantiate()
			board.name = parent
			get_tree().current_scene.get_node("Boards").add_child(board)
		get_tree().current_scene.get_node("Boards/" + parent).call_deferred("add_child", obj)
		obj.Data["ID"] = parent
	else:
		if !get_tree().current_scene.get_node("Boards/" + User.CurrentPage):
			get_tree().current_scene.get_node("Boards/Home").call_deferred("add_child", obj)
		else:
			get_tree().current_scene.get_node("Boards/" + User.CurrentPage).call_deferred("add_child", obj)
		obj.Data["ID"] = User.CurrentPage
	if GetSpecificType(obj, [Button, Control, TextEdit]):
		obj.position = User.MousePos
	if !extraData.is_empty() and (extraData["Pos"] != Vector2.ZERO and extraData["Size"] != Vector2.ZERO):
		obj.position = extraData["Pos"]
		obj.size = extraData["Size"]
	User.emit_signal("ObjectAdded", obj.Data)


func GetSpecificType(Item, TypeArray: Array):
	var result = false
	for i in TypeArray:
		if typeof(Item) == typeof(i):
			result = true
	return result
