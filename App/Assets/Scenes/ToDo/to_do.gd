extends Item

@onready var input: LineEdit = $AddHolder/Input
@onready var progress: Label = $Top/Progress/Label

var Data: = {
	"Type": "ToDo", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"List": {}, 
	"ID": "Home", 
	"TitleOn": true, 
	"Title": "",
	"FontSize" : Settings.Data["DefaultFontSize"],
	"TitleSize": Settings.Data["DefaultTitleSize"],
	"ShowProgress" : true,
	"ItemID" : -1,
	"Tags" : [],
	"Style" : ""
}

var Options := [
	"Ratio",
	"Title",
	"FontSize",
	"TitleSize",
	"Progress",
	"Move"
]
var TempTitleSize := 0
var LetGo := false
var HoverMove := false

func _ready() -> void:
	add_to_group("todo_container")
	initItem()
	ApplyData()
	User.connect("SwappingTodo", CreateMoveBars)
	size.y = 1

func ApplyData():
	if !Data["List"] is Dictionary:
		return
	ForceUpdateList(true)
	UpdateValues($Top/Title, "TitleOn", "visible")
	UpdateValues($Top/Title, "Title", "text")
	UpdateValues($Top/Progress, "ShowProgress", "visible")
	
	$Top/Title.add_theme_font_size_override("font_size", Data["TitleSize"])
	CalculateProgress()

func get_todo_items():
	var items = []
	for child in $List.get_children():
		if !child.is_in_group("move_bar") and !child.is_in_group("temp"):
			items.append(child)
	return items

func ForceUpdateList(useData = false):
	if !useData:
		Data["List"] = {}
		var Count = 0
		for i in $List.get_children():
			if !i.is_in_group("Move"):
				i.ID = Count
				i.name = str(Count)
				Data["List"][Count] = {"Text": i.Text, "Value": i.get_node("Input").button_pressed}
				Count += 1
	else:
		for i in Data["List"]:
			AddList(i, Data["List"][i]["Text"], Data["List"][i]["Value"])

func TodoClosed(Task):
	if Task is Array:
		Task = Task[0]
	TempTitleSize = $Top/Title.size.y
	$Top/Title.size.y = TempTitleSize
	Data["List"].erase(Task.ID)
	Task.queue_free()
	CalculateProgress()

func ChangeTitleSize(value: int):
	$Top/Title.add_theme_font_size_override("font_size", value)
	Data["TitleSize"] = value

func ChangeFontSize(value: int):
	if Data.has("FontSize"):
		if $List.get_children().size() >= 1:
			for i in $List.get_children():
				if i.has_method("ChangeFontSize"):
					i.ChangeFontSize(Data["FontSize"])
	Data["FontSize"] = value

func CalculateProgress():
	var Total = Data["List"].size()
	if Total <= 0:
		progress.text = "0%"
		$Top/Progress.self_modulate = Color.RED
	else:
		var Completed := 0
		for i in Data["List"].size():
			if Data["List"][Data["List"].keys()[i]]["Value"]:
				Completed += 1
		var progressValue = int(float(Completed) / float(Total) * 100)
		progress.text = str(progressValue) + "%"
		var BGCOL = Color(1.0 - (float(progressValue) / 100 * 1), (float(progressValue) / 100 * 1), 0.0, 1.0)
		$Top/Progress.self_modulate = BGCOL


func _process(_delta: float) -> void:
	Data["Pos"] = position
	Data["Size"] = size
	Data["TitleOn"] = $Top/Title.visible
	Data["Title"] = $Top/Title.text
	Data["ShowProgress"] = $Top/Progress.visible
	$List.visible = true if Data["List"].size() >= 1 else false

func AddList(ID, Text, Value, Moved = false, index = -1):
	if Text.strip_edges() == "":
		return false
	if index == -1:
		index = get_todo_items().size()
	
	var Output = true
	if Moved:
		for i in Data["List"]:
			if Data["List"][i]["Text"] == Text:
				Output = false
	else:
		$AddHolder/Input.clear()
		var Check = preload("res://App/Assets/Scenes/ToDo/check_list.tscn").instantiate()
		Check.Text = Text
		Check.get_node("Input").set_pressed_no_signal(Value)
		Check.get_node("Move").connect("pressed", MovePressed.bind(Check))
		Check.ID = ID
		if !Data["List"].has(ID):
			Data["List"].merge({ID: {"Text": Text, "Value": Value}}, true)
		else:
			if Data["List"][ID]["Text"] != Text and Output:
				Data["List"].merge({Data["List"].size(): {"Text": Text, "Value": Value}}, true)
		if Output:
			$List.add_child(Check)
			$List.move_child(Check, index)
			Check.name = str(ID)
			LoadConnections()
			Check.ChangeFontSize(Data["FontSize"])
			Check.get_node("Close").connect("pressed", TodoClosed.bind(ID))
			CalculateProgress()
	CreateStyle()
	return Output

func _on_add_pressed() -> void:
	var text = $AddHolder/Input.text
	if text.strip_edges() != "":
		AddList(Data["List"].size(), text, false)

func _on_input_text_submitted(new_text: String) -> void:
	if new_text.strip_edges() != "":
		AddList(Data["List"].size(), new_text, false)

func _on_title_on_pressed() -> void:
	$Top/Title.visible = !$Top/Title.visible


func _on_progress_pressed() -> void:
	if $Top/Progress.custom_maximum_size.y == -1:
		$Top/Progress.custom_maximum_size.y = 6
		progress.visible = false
	else:
		$Top/Progress.custom_maximum_size.y = -1
		progress.visible = true
	CalculateProgress()

func CreateMoveBars():
	ForceUpdateList()
	if int(Data["ItemID"]) == User.TodoParentID:
		size.y = 1
		return
	if !User.TodoSwitching:
		for i in $List.get_children():
			if i.is_in_group("Move"):
				i.queue_free()
		size.y = 1
	else:
		var Count = 0
		for i in $List.get_child_count() + 1:
			var butt = preload("res://App/Assets/Scenes/ToDo/move_todo.tscn").instantiate()
			$List.add_child(butt)
			$List.move_child(butt, Count)
			Count += 2
			butt.connect("pressed", MoveTask.bind(Count))

func MoveTask(Index : int):
	AddList(
		User.TodoTask["ID"],
		User.TodoTask["Text"],
		User.TodoTask["Value"],
		false,
		Index-1
	)
	User.TodoSwitching = false
	User.TodoNode.queue_free()
	User.emit_signal("SwappingTodo")
	User.emit_signal("CallItem", User.TodoParentID, "ToDo", "TodoClosed", [User.TodoNode])
	User.ShowMoveButton = false

func MovePressed(TaskNode):
	if !User.TodoSwitching:
		User.TodoSwitching = true
		User.TodoParentID = int(Data["ItemID"])
		User.TodoTask = {
			"Text": TaskNode.Text,
			"Value" : TaskNode.Value,
			"ID": TaskNode.ID
		}
		TaskNode.get_node("Move").visible = false
		User.TodoNode = TaskNode
		User.emit_signal("SwappingTodo")
	else:
		if int(Data["ItemID"]) == User.TodoParentID:
			var TempData = {
				"Text": TaskNode.Text,
				"Value" : TaskNode.Value,
				"ID": TaskNode.ID
			}
			TaskNode.SetData(User.TodoTask)
			User.TodoNode.SetData(TempData)
			Data["List"].merge({TempData["ID"] : {"Text": User.TodoNode.Text, "Value": User.TodoNode.Value}}, true)
			Data["List"].merge({User.TodoNode.ID: {"Text": TempData["Text"], "Value": TempData["Value"]}},true)
			User.TodoNode.get_node("Move").visible = true
			User.TodoSwitching = false
			CalculateProgress()
			User.emit_signal("SwappingTodo")
			User.ShowMoveButton = false
		else:
			pass
