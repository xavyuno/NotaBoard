extends HBoxContainer

@onready var info: = $Info
@onready var progress: TextureProgressBar = $Info/Progress
@onready var despawn: Timer = $Despawn

var Text :String
var Warning := false

func _ready() -> void:
	if Warning:
		progress.modulate = Color.RED
	else:
		progress.modulate = Color.GREEN
	progress.modulate.a = .5
	info.text = Text
	despawn.wait_time = Settings.Data["NotifTimeout"]
	despawn.start()
	progress.max_value = despawn.wait_time

func _process(_delta: float) -> void:
	progress.value = despawn.time_left

func _on_despawn_timeout() -> void:
	queue_free()

func _on_info_pressed() -> void:
	queue_free()
