extends VBoxContainer

@onready var items: VBoxContainer = $Items

var Data: = {
	"Type": "Column", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"Title": "", 
	"Items": [], 
	"ID": "Home"
}

var MouseIndropBar = false

func _process(delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size
	Data["Title"] = $Title.text
	$DropBar.visible = User.DraggingObject

func _ready() -> void :
	User.connect("StoppedDragging", Callable(self, "StoppedDragging"))
	UpdateValues($Title, "Title", "text")
	for i in Data["Items"]:
		if User.ProgressiveLoading:
			await get_tree().create_timer(User.LoadDur).timeout
		InitObjectData(i)

func UpdateValues(NODE, value, parameter):
	if Data.has(value):
		NODE.call_deferred("set", parameter, Data[value])

func GetData():
	var tempData = []
	for i in items.get_children(true):
		if i.has_method("GetData"):
			tempData.append(i.GetData())
	Data["Items"] = tempData
	return Data

func InitObjectData(data):
	var object = load("res://App/Assets/Scenes/" + data["Type"] + "/" + data["Type"] + ".tscn")
	var item = object.instantiate()
	if !(object in [
		preload("res://App/Assets/Scenes/Notes/Notes.tscn"), 


		]):
		if item.has_node("ExpandHolder"):
			item.get_node("ExpandHolder").visible = false
		if item.has_node("OptionsHolder/Expand"):
			item.get_node("OptionsHolder/Expand").visible = false
	else:
		if item.has_node("ExpandHolder/Expand"):
			item.get_node("ExpandHolder/Expand").DragMinOnly = true
			item.get_node("ExpandHolder/Expand").DragYAxisOnly = false
		elif item.has_node("OptionsHolder/Expand"):
			item.get_node("OptionsHolder/Expand").DragMinOnly = true
			item.get_node("OptionsHolder/Expand").DragYAxisOnly = true
	if item.has_node("OptionsHolder"):
		item.get_node("OptionsHolder").IncludeMove = false
	item.Data = data
	$Items.add_child(item)

func InitObject(object):
	var item = object.instantiate()
	if !(object in [
		preload("res://App/Assets/Scenes/Notes/Notes.tscn"), 
		]):
		if item.has_node("ExpandHolder"):
			item.get_node("ExpandHolder").visible = false
		if item.has_node("OptionsHolder/Expand"):
			item.get_node("OptionsHolder/Expand").visible = false
	else:
		if item.has_node("ExpandHolder/Expand"):
			item.get_node("ExpandHolder/Expand").DragMinOnly = true
			item.get_node("ExpandHolder/Expand").DragYAxisOnly = false
		elif item.has_node("OptionsHolder/Expand"):
			item.get_node("OptionsHolder/Expand").DragMinOnly = true
			item.get_node("OptionsHolder/Expand").DragYAxisOnly = true
	if item.has_node("OptionsHolder"):
		item.get_node("OptionsHolder").IncludeMove = false
	$Items.add_child(item)
	Data["Items"].append(item.Data)

func StoppedDragging():
	if User.DraggingObject and MouseIndropBar:
		User.DraggingObject = false

		InitObject(User.DraggedObject)

func _on_drop_bar_mouse_entered() -> void :
	MouseIndropBar = true

func _on_drop_bar_mouse_exited() -> void :
	MouseIndropBar = false
