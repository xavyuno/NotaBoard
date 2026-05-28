@tool
extends Control

@onready var input: LineEdit = $Holder/Input
@onready var add_task: Button = $Holder/AddTask
@onready var reload_tasks: Button = $Holder/ReloadTasks
@onready var tasks: VBoxContainer = $Holder/Tasks/Holder


var DevTasks := {}
var SaveFile := "res://addons/DevTasks/tasks.txt"

func _ready() -> void:
	Load()
	add_task.connect("pressed", Callable(self, "TaskAdded"))
	reload_tasks.connect("pressed", Callable(self, "ReloadTasks"))
	input.connect("text_submitted", Callable(self, "TaskSubmitted"))
	LoadTasks()

func TaskSubmitted(txt):
	DevTasks.merge({input.text : false}, true)
	var task = preload("res://addons/DevTasks/task.tscn").instantiate()
	tasks.add_child(task)
	task.get_node("Info").text = input.text
	input.text = ""

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		Save()

func LoadTasks():
	if DevTasks.size() >= 1:
		for i in DevTasks.keys():
			var task = preload("res://addons/DevTasks/task.tscn").instantiate()
			tasks.add_child(task)
			task.UpdateData(i, DevTasks[i])

func ReloadTasks():
	Save()
	for i in tasks.get_children():
		i.queue_free()
	LoadTasks()

func TaskAdded():
	DevTasks.merge({input.text : false}, true)
	var task = preload("res://addons/DevTasks/task.tscn").instantiate()
	tasks.add_child(task)
	task.get_node("Info").text = input.text
	input.text = ""

func Save():
	DevTasks = {}
	for i in tasks.get_child_count():
		var taskinfo = tasks.get_child(i).get_node("Info").text
		var value = tasks.get_child(i).get_node("Info").button_pressed
		DevTasks.merge({taskinfo : value}, true)
	var file = FileAccess.open(SaveFile, FileAccess.WRITE)
	file.store_var(DevTasks)
	file.close()

func Load():
	var file = FileAccess.open(SaveFile, FileAccess.READ)
	if file.file_exists(SaveFile):
		DevTasks = file.get_var()
	file.close()

func _exit_tree() -> void:
	Save()
