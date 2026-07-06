extends Item

@onready var RichText: RichTextLabel = $Preview/Edit/Text
@onready var NotesText: CodeEdit = $ScrollContainer/Notes


var Data: = {
	"Type": "Notes", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"Note": "", 
	"ID": "Home", 
	"Title": "", 
	"TitleOn": true, 
	"NoteOn": true,
	"FontSize" : Settings.DefaultFontSize,
	"TitleSize": Settings.DefaultTtileSize
}

var Options := [
	"Title",
	"FontSize",
	"TitleSize"
]

var Editing := false
var ClickedOnce := false

func _ready() -> void :
	initItem()
	EditNotes(false)
	UpdateValues(NotesText, "Note", "text")
	UpdateValues($Title, "Title", "text")
	UpdateValues($Title, "TitleOn", "visible")
	UpdateValues(RichText, "Note", "text")
	if Data.has("FontSize"):
		ChangeFontSize(Data["FontSize"])
	else :
		ChangeFontSize(Settings.DefaultFontSize)
	if Data.has("TitleSize"):
		ChangeTitleSize(Data["TitleSize"])
	else :
		ChangeTitleSize(Settings.DefaultFontSize)

	User.connect("PreviewNotes", Callable(self, "PreviewNotes"))

func ChangeTitleSize(value : int):
	$Title.add_theme_font_size_override("font_size", value)
	Data["TitleSize"] = value

func ChangeFontSize(value : int):
	$Preview/Edit/Text.add_theme_font_size_override("bold_font_size", value)
	$Preview/Edit/Text.add_theme_font_size_override("bold_italics_font_size", value)
	$Preview/Edit/Text.add_theme_font_size_override("italics_font_size", value)
	$Preview/Edit/Text.add_theme_font_size_override("mono_font_size", value)
	$Preview/Edit/Text.add_theme_font_size_override("normal_font_size", value)
	Data["FontSize"] = value

func _process(delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size
	Data["Note"] = NotesText.text
	Data["Title"] = $Title.text
	Data["TitleOn"] = $Title.visible
	if !Editing:
		Data["NoteOn"] = $Preview.visible
		RichText.text = NotesText.text
			
	
	if Input.is_action_just_pressed("Bold") and Editing:
		RichTextUpdate("b")


func ExtraUI(view: bool):
	$OptionsHolder.visible = view
	$ExpandHolder.visible = view

func _on_title_on_pressed() -> void :
	$Title.visible = !$Title.visible

func _on_note_on_pressed() -> void :
	$Preview.visible = !$Preview.visible

func _on_double_click_timeout() -> void:
	ClickedOnce = false

func EditNotes(GrabFocus = true):
	if User.PreviewingNotes:
		return
	$Preview.visible = !Editing
	$ScrollContainer.visible = Editing
	if GrabFocus:
		NotesText.grab_focus()

func _on_edit_pressed() -> void:
	if ClickedOnce:
		ClickedOnce = false
		Editing = true
		EditNotes()
	else :
		ClickedOnce = true
		$Preview/Edit/DoubleClick.start()

func _on_notes_focus_exited() -> void:
	Editing = false
	EditNotes(false)

func _on_text_focus_entered() -> void:
	Editing = true
	EditNotes(false)

func PreviewNotes():
	if User.PreviewingNotes:
		RichText.mouse_filter = Control.MOUSE_FILTER_PASS
	else :
		RichText.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _on_text_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

func RichTextUpdate(text, additonal = ""):
	if NotesText.get_selected_text():
		var selText = NotesText.get_selected_text()
		NotesText.insert_text("[" + text + additonal + "]", NotesText.get_caret_line(), NotesText.get_caret_column(), true, true)
		NotesText.insert_text("[/" + text + "]", NotesText.get_caret_line(), NotesText.get_caret_column() + selText.length(), false, false)
	else :
		NotesText.insert_text("[" + text + "]", NotesText.get_caret_line(), NotesText.get_caret_column(), true, true)
		NotesText.insert_text("[/" + text + "]", NotesText.get_caret_line(), NotesText.get_caret_column(), false, false)

func _on_bold_pressed() -> void:
	RichTextUpdate("b")

func _on_text_meta_hover_started(meta: Variant) -> void:
	RichText.tooltip_text = str(meta)

func _on_text_meta_hover_ended(meta: Variant) -> void:
	RichText.tooltip_text = ""


func _on_notes_code_completion_requested() -> void:
	print("pass")
