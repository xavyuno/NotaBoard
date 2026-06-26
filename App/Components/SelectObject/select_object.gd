extends Node

@export var Par = get_parent()
var Selected := false
var Action := ""
var Holding := false
var StillHolding := false
var TechnicallyInFocus := false

var buttons := []

func _ready() -> void :
	User.connect("StoppedSelecting", Callable(self, "StoppedSelecting"))
	User.connect("Searched", Callable(self, "Searched"))
	for i in Par.get_children(true):
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

func button_up():
	if !StillHolding:
		Holding = false
	$Timer.stop()

func button_down():
	$Timer.start()

func Searched(itemName):
	if itemName == "":
		Par.visible = true
		return
	if ValidateSearch(itemName, "Type"):
		Par.visible = true
	elif ValidateSearch(itemName, "Note"):
		Par.visible = true
	elif ValidateSearch(itemName, "Title"):
		Par.visible = true
	elif ValidateSearch(itemName, "Board"):
		Par.visible = true
	elif ValidateSearch(itemName, "ID"):
		Par.visible = true
	elif ValidateSearch(itemName, "List"):
		Par.visible = true
	elif ValidateSearch(itemName, "Dir"):
		Par.visible = true
	elif ValidateSearch(itemName, "Link"):
		Par.visible = true
	elif ValidateSearch(itemName, "Items"):
		Par.visible = true

	else :
		Par.visible = false

func ValidateSearch(itemName : String, Type : String):
	if !Par.has_method("GetData"):
		return
	if Par.Data.has(Type):
		if Par.Data is Dictionary or Par.Data is Array:
			if itemName in Par.Data[Type]:
				return true
			else :
				return false
		else :
			if Par.Data[Type].similarity(itemName) >= 0.8:
				return true
			else :
				return false
	else :
		return false

func StoppedSelecting():
	Selected = false
	Action = ""

func _physics_process(delta: float) -> void:
	if TechnicallyInFocus and !User.MouseInCanvas:
		ext()
	if Holding and Input.is_action_just_released("Click"):
		StillHolding = false
		Holding = false
		if User.MultiSelecting:
			if !(Par.get_path() in User.MultiSelectedObjects):
				User.MultiSelectedObjects.append(Par.get_path())
				Selected = true
			User.SelectedObject = null
		else:
			User.MultiSelectedObjects = []
			User.SelectedObject = Par.get_path()
			Selected = true
			User.emit_signal("ItemFocused", Par.get_path())
		User.emit_signal("SaveObjectData")
	if Input.is_action_just_pressed("Click") and (Action == "Moving" or Action == "Resizing"):
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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Holding:
			Par.position += event.relative / User.CamZoom
		if Action == "Moving":
			Par.position += event.relative / User.CamZoom
		if Action == "Resizing" :
			Par.size += event.relative / User.CamZoom

func FocusEntered():
	if User.MultiSelecting:
		if !(Par.get_path() in User.MultiSelectedObjects):
			User.MultiSelectedObjects.append(Par.get_path())
			Selected = true
		User.SelectedObject = null
	else:
		User.MultiSelectedObjects = []
		User.SelectedObject = Par.get_path()
		Selected = true
		User.emit_signal("ItemFocused", Par.get_path())
	User.emit_signal("SaveObjectData")

func ext():
	TechnicallyInFocus = false
	User.emit_signal("ItemFocusLost")
	User.emit_signal("SaveObjectData")
	if !User.MultiSelecting:
		Selected = false
		Action = ""

func FocusExited():
	if !User.MouseInCanvas or TechnicallyInFocus:
		ext()
	else :
		TechnicallyInFocus = true

func _on_timer_timeout() -> void:
	Holding = true
	StillHolding = true
	for i in buttons:
		i.release_focus()
