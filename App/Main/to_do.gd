@tool
extends VBoxContainer

var tasks : Dictionary

func _ready() -> void:
	if !Engine.is_editor_hint():
		tasks = System.LoadDevTasks()
		for i in tasks.keys():
			var task = preload("res://App/Components/DevTask/dev_task.tscn").instantiate()
			task.button_pressed = tasks[i]
			task.text = i
			$List.add_child(task)
	if Engine.is_editor_hint():
		LoadInEditor()

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_R) and Engine.is_editor_hint():
		LoadInEditor()

func LoadInEditor():
	var file = FileAccess.open("res://addons/DevTasks/tasks.txt", FileAccess.READ)
	tasks = file.get_var()
	for i in $List.get_children():
		i.queue_free()
	for i in tasks.keys():
		var task = preload("res://App/Components/DevTask/dev_task.tscn").instantiate()
		task.button_pressed = tasks[i]
		task.text = i
		$List.add_child(task)
