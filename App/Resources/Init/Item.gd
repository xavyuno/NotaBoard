extends VBoxContainer
class_name Item

var InColumn := false
var DragSelected := false

func AddData(extraData : Array):
	for i in extraData:
		self.Data.merge(i, true)

func GetData() -> Dictionary:
	return self.Data

func UpdateValues(NODE, value, parameter):
	NODE.call_deferred("set", parameter, Has(value))
	return Has(value)

# SELECT OBJECT CODE BELOW

@export var CanMove := true
@export var CanResizeX := true
@export var CanResizeY := true
var Selected := false
var MultiSelected := false
var Action := ""
var Holding := false
var StillHolding := false
var InitialDragPos := Vector2.ZERO
var TechnicallyInFocus := false

var buttons := []

var TimerNode : Timer = null
var Col : CollisionPolygon2D = null
var Body : StaticBody2D = null

var MouseClose := false
var Hovering = false

var PrevData := {}

func Has(ITEM : String, CustomValue = null):
	if CustomValue != null:
		return type_convert(self.Data[ITEM], typeof(CustomValue))
	else:
		return self.Data[ITEM]

func initItem():
	add_to_group("Item")
	if self.Data["ItemID"] is String:
		self.Data["ItemID"] = int(self.Data["ItemID"])

	if self.Data["Size"] != Vector2.ZERO:
		size = self.Data["Size"]
		position = self.Data["Pos"]
	TimerNode = Timer.new()
	TimerNode.one_shot = true
	TimerNode.wait_time = 0.5
	self.add_child(TimerNode)
	TimerNode.connect("timeout", Callable(self, "Timeout"))
	
	Body = StaticBody2D.new()
	self.add_child(Body)

	Col = CollisionPolygon2D.new()
	Body.add_child(Col)
	Col.polygon = System.CreateRectangle(Vector2.ZERO, size)
	User.connect("StoppedSelecting", Callable(self, "StoppedSelecting"))
	User.connect("Searched", Callable(self, "Searched"))
	User.connect("AllFocusLost", Callable(self, "AllFocusLost"))
	User.connect("SearchByQuery", Callable(self, "SearchByQuery"))
	User.connect("DeleteAllItemsByBoard", Callable(self, "DeleteAllItemsByBoard"))
	User.connect("ApplyItemChange", Callable(self, "ApplyItemChange"))
	User.connect("CallItem", CallItem)
	Customization.connect("ApplyCustomization", CreateStyle)
	
	LoadConnections()
	if Settings.Data["LoadCustomThemes"]:
		CreateStyle("")

func CallItem(ID : int, type : String, Func : String, Args:Array):
	if self.Data["ItemID"] == ID and self.Data["Type"] == type:
		call(Func, Args)

func _draw() -> void:
	if Selected and Settings.Data["CanSelectCol"]:
		var Style : StyleBox = _resolve_style()["Style"].duplicate(true)
		if Style is StyleBoxEmpty or !Settings.Data["LoadCustomThemes"]:
			Style = StyleBoxFlat.new()
		Style.set("bg_color", Color(0.0, 0.0, 0.0, 0.0))
		Style.call("set_border_width_all", (4 / User.CamZoom.x))
		Style.shadow_color = Color(0.0, 0.0, 0.0, 0.1)
		Style.shadow_size = 8
		Style.border_color = Settings.Data["SelectCol"]
		draw_style_box(Style, Rect2(0, 0, size.x, size.y))

func CreateStyle(Altered = ""):
	ApplyStyle(get_children(true), Altered)

func ApplyStyle(Nodes: Array, Altered := "") -> void:
	var Style: Dictionary = _resolve_style()
	var font: Font = null
	if Altered == "" or Altered == "Font":
		font = System.LoadFont(Style["Font"])

	for i: Node in Nodes:
		if i.is_in_group("Ignore"):
			continue
		if not (i.has_method("add_theme_color_override")
				or i.has_method("add_theme_font_override")
				or i.has_method("add_theme_stylebox_override")):
			continue

		if i is Button or i is LineEdit or i is RichTextLabel or i is CodeEdit:
			_apply_node_style(i, Style, Altered, font)

		if i.get_child_count() >= 1:
			ApplyStyle(i.get_children(true), Altered)

func _resolve_style() -> Dictionary:
	if !self.Data["Style"] is String:
		return Customization.Themes[Customization.Config[self.Data["Type"]]].duplicate(true)
	if !self.Data["Style"] in ["None", ""]:
		return Customization.Themes[self.Data["Style"]].duplicate(true)
	return Customization.Themes[Customization.Config[self.Data["Type"]]].duplicate(true)


func _apply_node_style(i: Node, Style: Dictionary, Altered: String, font: Font) -> void:
	if (Altered == "" or Altered == "FontColor") and i.has_method("add_theme_color_override") and Customization.Themes[Customization.SelectedTheme].has("FontColor"):
		for j in System.GetFontColors(i):
			i.add_theme_color_override(j, Style["FontColor"])

	if (Altered == "" or Altered == "Font") and i.has_method("add_theme_font_override"):
		for j in System.GetFontOptions(i):
			i.add_theme_font_override(j, font)

	if (Altered == "" or Altered == "Style") and i.has_method("add_theme_stylebox_override"):
		for j in System.GetStyleOptions(i):
			if Style["Style"] is StyleBox:
				var box = _build_stylebox(i, Style["Style"])
				i.add_theme_stylebox_override(j, box)


func _build_stylebox(i: Node, base: StyleBox) -> StyleBox:
	if not (base is StyleBoxFlat):
		return base

	var box: StyleBoxFlat = base.duplicate(true)

	if i.is_in_group("Left"):
		box.set_corner_radius(CORNER_BOTTOM_RIGHT, 0)
	if i.is_in_group("Right"):
		box.set_corner_radius(CORNER_BOTTOM_LEFT, 0)
	if i.is_in_group("Middle"):
		box.set_corner_radius_all(0)
	if i.is_in_group("Empty"):
		return StyleBoxEmpty.new()
	if i.is_in_group("Top"):
		box.set_corner_radius(CORNER_BOTTOM_LEFT, 0)
		box.set_corner_radius(CORNER_BOTTOM_RIGHT, 0)
	if i.is_in_group("Bottom"):
		if self.Data["Type"] == "Notes" and $Title.visible:
			box.set_corner_radius(CORNER_TOP_LEFT, 0)
			box.set_corner_radius(CORNER_TOP_RIGHT, 0)
		elif self.Data["Type"] != "Notes":
			box.set_corner_radius(CORNER_TOP_LEFT, 0)
			box.set_corner_radius(CORNER_TOP_RIGHT, 0)
	return box

func ApplyItemChange(data):
	if data["ItemID"] == self.Data["ItemID"]:
		self.Data = data
		position = data["Pos"]
		size = data["Size"]
		call("ApplyData")

func LoadConnections():
	Connect(self.get_children(true), 
	["focus_entered", "focus_exited", "button_down", "button_up"])


func ApplyToAll(NODES : Array, FUNCTIONS : Array):
	for i in NODES:
		for j in FUNCTIONS:
			call(j, i)
		if i.get_children(true).size() >= 1:
			Connect(i.get_children(true), FUNCTIONS)

func Connect(NODES : Array, SIGNALS : Array):
	#This ladies and gentlemen is called "Recurrsion" (probably)
	for i in NODES:
		for j in SIGNALS:
			if i.has_signal(j):
				if !i.is_connected(j, Callable(self, j)):
					i.connect(j, Callable(self, j))
		if i.get_children(true).size() >= 1:
			Connect(i.get_children(true), SIGNALS)

func SearchByQuery(ID : String):
	var TempFound := false
	var Query = ID.split(":", true, 1)
	if Query.size() <= 1:
		var NewQuery = User.SearchQueries
		NewQuery.erase("Type:")
		for i in NewQuery:
			if TempFound:
				break
			if SearchSimilarity(ID, i.replace(":", ""), true) and !TempFound:
				TempFound = true
				System.GoTo(self.Data)
	else:
		if Query[0].capitalize() + ":" in User.SearchQueries:
			if SearchSimilarity(Query[1].capitalize(), Query[0].capitalize(), true):
				System.GoTo(self.Data)

func Delete():
	User.emit_signal("ItemFocusLost")
	if self.Data["Type"] == "Board":
		Settings.Data["TotalBoards"] -= 1
	User.emit_signal("StoppedSelecting")
	User.MultiSelectedObjects = {}
	if !Input.is_action_pressed("Special"):
		User.emit_signal("ObjectRemoved", self.Data)
	User.emit_signal("ItemFocusLost")
	if self.Data["Type"] == "Board":
		if Settings.Data["WarnDeleteAllBoard"]:
			System.CreateWarning("Do you wish to delete all objects within this board?").connect("WarningSelectted", Callable(self, "Warning"))
		else:
			queue_free()
	else:
		queue_free()

func Warning(output):
	if output:
		User.emit_signal("DeleteAllItemsByBoard", self.Data["Board"])
	queue_free()

func AddTag(ID):
	self.Data["Tags"].append(ID)

func DeleteAllItemsByBoard(ID):
	if self.Data["ID"] == ID:
		Delete()

func button_up():
	if !StillHolding:
		Holding = false
	TimerNode.stop()

func button_down():
	if !CanMove:
		return
	InitialDragPos = get_global_mouse_position()
	TimerNode.start()

var Found := false

func Searched(itemName : String):
	Found = false
	if itemName == "":
		visible = true
		return
	var TotalQueries = itemName.split(" ")
	for j in TotalQueries:
		var Query = j.split(":", true, 1)
		if Query.size() <= 1:
			var NewQuery = User.SearchQueries
			NewQuery.erase("Type:")
			for i in NewQuery:
				if SearchSimilarity(itemName, i.replace(":", "")):
					visible = true
					Found = true
				else:
					if !Found:
						visible = false
					else:
						visible = true
		else:
			if Query[0] + ":" in User.SearchQueries:
				visible = SearchSimilarity(Query[1], Query[0])

func SearchSimilarity(Search : String, Query : String, Temp = false):
	var TempData : Dictionary = self.Data.duplicate(true)
	var Result = false
	if TempData.has(Query):
		if TempData[Query] is Array:
			for i in TempData[Query]:
				Result = ReturnSearchResult(Query, Search, TempData, i, Temp)
		else:
			Result = ReturnSearchResult(Query, Search, TempData, null, Temp)
	return Result

func ReturnSearchResult(Query, Search, TempData, TempValue = null, isTest = false):
	var Temp : String = str(TempData[Query])
	if TempValue != null:
		Temp = TempValue
	Temp = Temp.to_lower()
	if Temp.similarity(Search.to_lower()) >= User.SearchSen and !(TempData in User.SearchResults):
		TempData.merge({"Search" : Temp, "Query" : Query}, true)
		if TempData["ID"] != "Home":
			if User.Boards.has(TempData["ID"]):
				if User.Boards[TempData["ID"]]["Title"] != "":
					if !isTest:
						User.emit_signal("SearchResultSend", TempData)
					return true
				else:
					return false
			else :
				return false
		else:
			if !isTest:
				User.emit_signal("SearchResultSend", TempData)
			return true
	else:
		return false

func StoppedSelecting():
	Selected = false
	Action = ""

var InitialMousePos := Vector2.ZERO

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("SelectAll") and self.Data["ID"] == Settings.Data["CurrentPage"] and !User.InFocus:
		focus_entered()
	if Settings.Data["CurrentPage"] == self.Data["ID"]:
		var FullSize = global_position + size
		#print(FullSize, " | ", get_global_mouse_position())
		if (get_global_mouse_position().y >= global_position.y and get_global_mouse_position().y <= FullSize.y) and (get_global_mouse_position().x >= global_position.x and get_global_mouse_position().x <= FullSize.x):
			Hovering = true
		else:
			Hovering = false
		if Col != null:
			Col.disabled = false
	else:
		if Col != null:
			Col.disabled = true

	if TechnicallyInFocus and !User.MouseInCanvas:
		ext()
	if Input.is_action_just_released("Click"):
		if Holding:
			StillHolding = false
			Holding = false
			User.MultiSelectedObjects = {}
			System.AddItemToList(get_path(), self.Data["Type"])
			Selected = true
			User.emit_signal("ItemFocused", get_path())
			User.emit_signal("SaveObjectData")
	if Input.is_action_just_pressed("Click"):
		if DragSelected:
			ItemFocusLost()
		if (Action == "Moving" or Action == "Resizing"):
			Action = ""
			Selected = false
	if Input.is_action_just_pressed("Move") and Input.is_action_pressed("Command") and Selected:
		InitialMousePos = position
		if Action != "Moving":
			Action = "Moving"
		else :
			Action = ""
	if Input.is_action_just_pressed("Resize") and Input.is_action_pressed("Command") and Selected:
		if Action != "Resizing":
			Action = "Resizing"
		else :
			Action = ""
	if Input.is_action_just_pressed("Delete") and (Selected or DragSelected or MultiSelected):
		Delete()
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Holding and !InColumn:
			position = MouseMove(event.relative, position)
			User.DragSelecting = false
		if Action == "Moving" and !InColumn:
			position = MouseMove(event.relative, position)
		if Action == "Resizing":
			User.ConfineWindow = true
			if !InColumn:
				size = MouseMove(event.relative, size, true)
			else :
				custom_minimum_size.y = MouseMove(event.relative, size, true).y
			if self.Data["Type"] == "ToDo":
				size.y = 1
		else:
			User.ConfineWindow = false

func MouseMove(eventRelative : Vector2, vec, Resizing = false) -> Vector2:
	if !CanMove:
		return vec
	Col.polygon = System.CreateRectangle(Vector2.ZERO, size)
	var current_mouse = get_global_mouse_position()
	var offset = current_mouse - vec
	var NewPos : Vector2 = vec + (eventRelative / User.CamZoom)
	if Settings.Data["GridSnap"]:
		NewPos = vec + (eventRelative * (Settings.Data["GridSize"] / (Settings.Data["GridSize"] /2)) / User.CamZoom)
		NewPos = NewPos.snapped(Vector2(Settings.Data["GridSize"], Settings.Data["GridSize"]))
	if Resizing:
		if !CanResizeX:
			return Vector2(vec.x, NewPos.y)
		if !CanResizeY:
			return Vector2(NewPos.x, vec.y)
	return NewPos

func FocusItem():
	if !Selected or !MultiSelected:
		focus_entered(true)
	queue_redraw()

func AllFocusLost():
	if Selected or MultiSelected:
		Canvas.SelectedCanvas = false
		ext(true)
	queue_redraw()

func ItemFocusLost():
	pass
	#if DragSelected:
		#DragSelected = false
		#ext(true)

func focus_entered(MultiSelect = false):
	if !Selected:
		PrevData = self.Data.duplicate(true)
	if !(User.MultiSelecting or MultiSelect):
		User.emit_signal("AllFocusLost")
		DragSelected = false
		MultiSelected = false
		User.MultiSelectedObjects = {}
		System.AddItemToList(get_path(), self.Data["Type"])
	else:
		DragSelected = true
		MultiSelected = true
		if User.MultiSelectedObjects.has(self.Data["Type"]):
			if !(get_path() in User.MultiSelectedObjects[self.Data["Type"]]):
				System.AddItemToList(get_path(), self.Data["Type"])
			else :
				System.RemoveItemFromList(get_path(), self.Data["Type"])
				ext(true)
				return
		else:
			System.AddItemToList(get_path(), self.Data["Type"])
	if self.Data["Type"] == "Canvas":
		Canvas.SelectedCanvas = true
	Selected = true
	User.emit_signal("ItemFocused", get_path())
	User.emit_signal("SaveObjectData")
	queue_redraw()

func ext(force = false):
	TechnicallyInFocus = false
	User.emit_signal("SaveObjectData")
	if (!User.MultiSelecting and !DragSelected) or force:
		Selected = false
		MultiSelected = false
		Action = ""
		if PrevData != self.Data:
			if self.Data["Type"] == "Notes":
				if !self.Editing:
					User.emit_signal("ItemChanged", PrevData)
			else:
				User.emit_signal("ItemChanged", PrevData)
	else :
		User.emit_signal("ItemFocusLost")
	queue_redraw()

func focus_exited():
	if Selected or MultiSelected:
		if (!User.MouseInCanvas or TechnicallyInFocus):
			ext()
		else :
			TechnicallyInFocus = true
	queue_redraw()

var OffsetPos = Vector2.ZERO

func Timeout() -> void:
	Holding = true
	StillHolding = true
	OffsetPos =  InitialDragPos - position
	position = get_global_mouse_position() - OffsetPos
	for i in buttons:
		i.release_focus()
