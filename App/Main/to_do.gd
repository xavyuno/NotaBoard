extends VBoxContainer

func _ready() -> void:
	var tasks : Dictionary = System.LoadDevTasks()
	for i in tasks.keys():
		var task = preload("res://App/Components/DevTask/dev_task.tscn").instantiate()
		task.button_pressed = tasks[i]
		task.text = i
		$List.add_child(task)
