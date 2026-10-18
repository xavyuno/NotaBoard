extends HBoxContainer

var Text: = ""
var Editing := false
var ClickedOnce := false
var ID := 0
var Holding := false

func _ready() -> void:
	$Text.text = Text
	$TextEdit.text = Text
	User.connect("AllFocusLost", Callable(self, "LostFocus"))

func LostFocus():
	Editing = false
	Update($Input.button_pressed)

func _process(_delta: float) -> void:
	$Text.visible = !Editing
	$TextEdit.visible = Editing

func ChangeFontSize(value):
	$Text.add_theme_font_size_override("font_size", value)

func _on_input_toggled(toggled_on: bool) -> void:
	Update(toggled_on)

func _on_text_pressed() -> void:
	Update(!$Input.button_pressed)
	if ClickedOnce:
		Editing = true
	else:
		$Text/DoubleClick.start()
		ClickedOnce = true

func Update(state):
	if $"../..".Data["List"].has(ID):
		$"../..".Data["List"][ID]["Value"] = state
	$"../..".CalculateProgress()
	$Input.button_pressed = state

func _on_text_edit_text_changed(new_text: String) -> void:
	$Text.text = new_text
	$"../..".Data["List"][ID]["Text"] = new_text
