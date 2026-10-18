extends VBoxContainer

func _ready() -> void:
	User.connect("CreateNotif", Callable(self, "CreateNotif"))

func CreateNotif(Text: String):
	var Notif = preload("uid://t5wur25g413o").instantiate()
	Notif.Text = Text
	add_child(Notif)
