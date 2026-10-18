extends Item

@onready var RichText: RichTextLabel = $Text
@onready var NotesText: CodeEdit = $ScrollContainer/Notes

var Data: = {
	"Type": "Notes", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"Note": "", 
	"ID": "Home", 
	"Title": "", 
	"TitleOn": true, 
	"FontSize" : Settings.Data["DefaultFontSize"],
	"TitleSize": Settings.Data["DefaultTitleSize"],
	"ItemID" : "",
	"Tags" : [],
	"Style" : "",
	"AutoExpand" : true
}

var Options := [
	"Title",
	"FontSize",
	"TitleSize",
	"AutoExpand"
]

var Editing := false
var MouseHovering := false
var Displays = []

func _ready() -> void :
	initItem()
	ApplyData()
	Connect(get_children(true), ["mouse_entered", "mouse_exited"])
	User.connect("PreviewNotes", Callable(self, "PreviewNotes"))
	User.connect("AllFocusLost", Callable(self, "_on_notes_focus_exited"))
	User.connect("DeleteItem", Callable(self, "DeleteItem"))
	Settings.connect("SettingsChanged", UpdateText)

func ApplyData():
	$Text.fit_content = Data["AutoExpand"]
	EditNotes(false)
	UpdateValues(NotesText, "Note", "text")
	UpdateText()
	UpdateValues($Title, "Title", "text")
	UpdateValues($Title, "TitleOn", "visible")
	ChangeFontSize(Has("FontSize"))
	ChangeTitleSize(Has("TitleSize"))

func DeleteItem(ItemID):
	if self.Data["ItemID"] == ItemID:
		Delete()

func mouse_entered():
	if RichText.get_v_scroll_bar().max_value - RichText.size.y >= 0:
		User.InFocus = true


func mouse_exited():
	User.InFocus = false

func ChangeTitleSize(value : int):
	$Title.add_theme_font_size_override("font_size", value)
	Data["TitleSize"] = value

func ChangeFontSize(value : int):
	RichText.add_theme_font_size_override("bold_font_size", value)
	RichText.add_theme_font_size_override("bold_italics_font_size", value)
	RichText.add_theme_font_size_override("italics_font_size", value)
	RichText.add_theme_font_size_override("mono_font_size", value)
	RichText.add_theme_font_size_override("normal_font_size", value)
	$ScrollContainer/Notes.add_theme_font_size_override("font_size", value)
	Data["FontSize"] = value

func _process(_delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size
	Data["Note"] = NotesText.text
	Data["Title"] = $Title.text
	Data["TitleOn"] = $Title.visible
	Data["AutoExpand"] = $Text.fit_content
	if $ScrollContainer/Notes.get_v_scroll_bar().max_value > 0:
		$ScrollContainer.custom_minimum_size = $Text.size + Vector2(0, 48)
	
	QuickType("Bold", "b")
	QuickType("Italic", "i")

func QuickType(Keybind, command):
	if Input.is_action_just_pressed(Keybind) and Input.is_action_pressed("Command") and Editing:
		RichTextUpdate(command)

func EditNotes(GrabFocus = true):
	RichText.visible = !Editing
	$ScrollContainer.visible = Editing
	if GrabFocus:
		NotesText.grab_focus()

func _on_notes_focus_exited() -> void:
	if Editing:
		UpdateText()
		Editing = false
		EditNotes(false)

func CommandHovered(Hovered : bool, cmd : String):
	if !Hovered:
		pass
	else:
		if "display" in cmd:
			cmd = cmd.replace("display/", "")
			CreateDisplay(cmd)

func CreateDisplay(imagePath):
	var texture = ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(imagePath)))
	var display = TextureRect.new()
	display.texture = texture
	get_tree().current_scene.add_child(display)
	display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if !(display in Displays):
		Displays.append(display)
	display.offset_transform_enabled = true
	display.size /= User.CamZoom.x * 2
	display.offset_transform_position = get_global_mouse_position() - (display.size / 2)
	

func UpdateText():
	var Temptext : String = Data["Note"]
	if Settings.Data["NoteCommands"].size() >= 1:
		for i in Settings.Data["NoteCommands"]:
			var Startcmd = ""
			var EndCmd = ""
			var Occurences : Array = i.keys()
			var reversed = i.values()[0].split(" ")
			reversed.reverse()
			for a in i.keys():
				Occurences.append(a.to_lower())
				Occurences.append(a.to_upper())
				Occurences.append(a.capitalize())
			
			for j in i.values()[0].split(" "):
				Startcmd += HasCommand(j, " ")
			for j in reversed:
				EndCmd += HasCommand(j, true)
			for b in Occurences:
				var Replacement = (
					Startcmd +
					#MIDDLE/ THE TEXT BEING REPLACED
					b +
					# END OF TEXT
					EndCmd
					)
				Temptext = Temptext.replacen(b, 
					Replacement
					)
	RichText.text = Temptext

func HasCommand(Code : String, end = false):
	var output = "[" + Code + "]"
	if end:
		Code = Code.split("=")[0]
		output = "[/" + Code + "]"
	return output

func _on_text_focus_entered() -> void:
	Editing = true
	EditNotes(false)

	if $ScrollContainer/Notes.get_v_scroll_bar().max_value > 0:
		$ScrollContainer.custom_minimum_size = $Text.size + Vector2(0, 48)
	else:
		$ScrollContainer.custom_minimum_size = $Text.size

func _on_text_meta_clicked(meta ) -> void:
	for a in str(meta).to_lower().split('|'):
		meta = a.split('/')
		if !Commands.CheckCommand(meta):
			OS.shell_open(str(meta))

func RichTextUpdate(text):
	if NotesText.get_selected_text():
		var selText = NotesText.get_selected_text()
		NotesText.text = NotesText.text.replace(selText, "[" + text + "]" + selText + "[/" + text + "]")
	else :
		NotesText.insert_text("[" + text + "]", NotesText.get_caret_line(), NotesText.get_caret_column(), true, true)
		NotesText.insert_text("[/" + text + "]", NotesText.get_caret_line(), NotesText.get_caret_column(), false, false)


func _on_text_meta_hover_started(meta: Variant) -> void:
	MouseHovering = true
	for a in str(meta).to_lower().split('|'):
		if !Commands.CheckCommand(a.split('/'), true):
			RichText.tooltip_text = a
		else:
			if "display" in a:
				CreateDisplay(a.replace("display/", ""))

func _on_text_meta_hover_ended(_meta: Variant) -> void:
	MouseHovering = false
	RichText.tooltip_text = ""
	while Displays.size() >= 1:
		Displays[0].queue_free()
		Displays.pop_front()
