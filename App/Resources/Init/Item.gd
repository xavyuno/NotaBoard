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
	if self.Data.has(value):
		NODE.call_deferred("set", parameter, self.Data[value])

# SELECT OBJECT CODE BELOW

@export var CanDrag := true
var Selected := false
var MultiSelected := false
var Action := ""
var Holding := false
var StillHolding := false
var TechnicallyInFocus := false

var buttons := []

var TimerNode : Timer = null
var Col : CollisionPolygon2D = null
var Body : StaticBody2D = null

func initItem():
	User.TotalItems += 1
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
	User.connect("ChangeBoard", Callable(self, "ChangeBoard"))
	User.connect("AllFocusLost", Callable(self, "AllFocusLost"))
	for i in self.get_children(true):
		if i.get_child_count() >= 1:
			for j in i.get_children(true):
				if j.has_signal("focus_entered"):
					j.connect("focus_entered", Callable(self, "FocusEntered"))
					j.connect("focus_exited", Callable(self, "FocusExited"))
					
				if j.has_signal("button_down"):
					j.connect("button_down", Callable(self, "button_down"))
					buttons.append(j)
					j.connect("button_up", Callable(self, "button_up"))

		if i.has_signal("focus_entered"):
			i.connect("focus_entered", Callable(self, "FocusEntered"))
			i.connect("focus_exited", Callable(self, "FocusExited"))

		if i.has_signal("button_down"):
			i.connect("button_down", Callable(self, "button_down"))
			i.connect("button_up", Callable(self, "button_up"))
			buttons.append(i)

func ChangeBoard(Board: String, Title: String, ID = "", CamPos = Vector2(640, 352)):
	FocusExited()

func button_up():
	if !StillHolding:
		Holding = false
	TimerNode.stop()

func button_down():
	if User.MultiSelecting:
		MultiSelected = true
		if !(get_path() in User.MultiSelectedObjects):
			User.MultiSelectedObjects.append(get_path())
		else :
			User.MultiSelectedObjects.erase(get_path())
			ext(true)
	if !CanDrag:
		return
	TimerNode.start()

func Searched(itemName):
	if itemName == "":
		visible = true
		return
	if ValidateSearch(itemName, "Type"):
		visible = true
	elif ValidateSearch(itemName, "Note"):
		visible = true
	elif ValidateSearch(itemName, "Title"):
		visible = true
	elif ValidateSearch(itemName, "Board"):
		visible = true
	elif ValidateSearch(itemName, "ID"):
		visible = true
	elif ValidateSearch(itemName, "List"):
		visible = true
	elif ValidateSearch(itemName, "Dir"):
		visible = true
	elif ValidateSearch(itemName, "Link"):
		visible = true
	elif ValidateSearch(itemName, "Items"):
		visible = true

	else :
		visible = false

func ValidateSearch(itemName : String, Type : String):
	if !has_method("GetData"):
		return
	if self.Data.has(Type):
		if itemName in self.Data[Type]:
			return true
		else :
			return false
	elif self.Data[Type].similarity(itemName) >= 0.75:
			return true
	else :
		return false

func StoppedSelecting():
	Selected = false
	Action = ""

func _draw() -> void:
	if Selected and Settings.CanSelectCol:
		draw_rect(
			Rect2(0, 0, size.x, size.y),
			Settings.SelectCol,
			false,
			4,
			true
		)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("SelectAll") and self.Data["ID"] == User.CurrentPage:
		FocusEntered()
	if User.CurrentPage == self.Data["ID"]:
		if Col != null:
			Col.disabled = false
	else:
		if Col != null:
			Col.disabled = true

	if TechnicallyInFocus and !User.MouseInCanvas:
		ext()
	if Holding and Input.is_action_just_released("Click"):
		StillHolding = false
		Holding = false
		if User.MultiSelecting:
			if !(get_path() in User.MultiSelectedObjects):
				User.MultiSelectedObjects.append(get_path())
				Selected = true
			User.SelectedObject = null
		else:
			User.MultiSelectedObjects = []
			User.SelectedObject = get_path()
			Selected = true
			User.emit_signal("ItemFocused", get_path())
		User.emit_signal("SaveObjectData")
	if Input.is_action_just_pressed("Click"):
		if DragSelected:
			ItemFocusLost()
		if (Action == "Moving" or Action == "Resizing"):
			Action = ""
			Selected = false
	if Input.is_action_just_pressed("Move") and Selected:
		if Action != "Moving":
			Action = "Moving"
		else :
			Action = ""
	if Input.is_action_just_pressed("Resize") and Selected:
		if Action != "Resizing":
			Action = "Resizing"
		else :
			Action = ""
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Holding and !InColumn:
			position += event.relative / User.CamZoom
			User.DragSelecting = false
		if Action == "Moving" and !InColumn:
			position += event.relative / User.CamZoom
		if Action == "Resizing":
			if !InColumn:
				size += event.relative / User.CamZoom
			else :
				custom_minimum_size.y += event.relative.y / User.CamZoom.y

func FocusItem():
	FocusEntered(true)

func AllFocusLost():
	ext(true)

func ItemFocusLost():
	if DragSelected:
		DragSelected = false
		ext(true)

func FocusEntered(MultiSelect = false):
	if !(User.MultiSelecting or MultiSelect):
		DragSelected = false
		MultiSelected = false
		User.MultiSelectedObjects = []
		User.MultiSelectedObjects.append(get_path())
	if MultiSelect:
		DragSelected = true
		MultiSelected = true
		if !(get_path() in User.MultiSelectedObjects):
			User.MultiSelectedObjects.append(get_path())
		else :
			User.MultiSelectedObjects.erase(get_path())
			ext(true)
			return
	User.SelectedObject = get_path()
	Selected = true
	User.emit_signal("ItemFocused", get_path())
	User.emit_signal("SaveObjectData")

func ext(force = false):
	TechnicallyInFocus = false
	User.emit_signal("SaveObjectData")
	if (!User.MultiSelecting and !DragSelected) or force:
		Selected = false
		MultiSelected = false
		Action = ""
	else :
		User.emit_signal("ItemFocusLost")

func FocusExited():
	if (!User.MouseInCanvas or TechnicallyInFocus):
		ext()
	else :
		TechnicallyInFocus = true

func Timeout() -> void:
	Holding = true
	StillHolding = true
	for i in buttons:
		i.release_focus()
