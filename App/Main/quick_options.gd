extends Panel

var selected := 0

func _ready() -> void:
	for i in Settings.AvailableQuickOptions:
		var butt = Button.new()
		butt.custom_minimum_size = Vector2(32, 32)
		butt.name = i.to_kebab_case().replace("-", " ").capitalize()
		butt.text = i.to_kebab_case().replace("-", " ").capitalize()
		butt.pressed.connect(EditOption.bind(i))
		$ScrollHolder/Options.add_child(butt)
	for i in $QuickHolder.get_children():
		i.connect("pressed", Pressed.bind(int(i.name)))
	Pressed(1)

func Pressed(ID):
	selected = ID-1
	queue_redraw()
	for i in 3:
		get_node("QuickHolder/" + str(i+1)).icon = load("res://App/Assets/Icons/" + Settings.Data["QuickOptions"][i] + ".png")

func _process(_delta: float) -> void:
	$Title.text = Settings.Data["QuickOptions"][selected]

func _draw() -> void:
	if get_node("QuickHolder/" + str(selected+1)):
		var style : StyleBoxFlat = Customization.Themes["Application Default"]["Style"].duplicate()
		style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
		style.shadow_size = 12
		style.shadow_color = Color(0.0, 0.0, 0.0, 0.25)
		var POS = get_node("QuickHolder/" + str(selected+1)).position + Vector2(8,8)
		var SIZE = get_node("QuickHolder/" + str(selected+1)).size
		draw_style_box(
			style,
			Rect2(POS, SIZE)
	)

func EditOption(opt):
	Settings.Data["QuickOptions"][selected] = opt.replace("_", "")
	Settings.emit_signal("SettingsChanged")
	get_node("QuickHolder/" + str(selected+1)).icon = load("res://App/Assets/Icons/" + Settings.Data["QuickOptions"][selected] + ".png")
