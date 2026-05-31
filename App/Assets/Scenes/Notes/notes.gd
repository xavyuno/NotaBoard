extends VBoxContainer

@onready var RichText: RichTextLabel = $Preview/Edit/Text
@onready var NotesText: TextEdit = $ScrollContainer/Notes


var Data: = {
	"Type": "Notes", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"Note": "", 
	"ID": "Home", 
	"Title": "", 
	"TitleOn": true, 
	"NoteOn": true
}

var Editing := false
var ClickedOnce := false

func _ready() -> void :
	EditNotes()
	UpdateValues(NotesText, "Note", "text")
	UpdateValues($Preview, "NoteOn", "visible")
	UpdateValues($Title, "Title", "text")
	UpdateValues($Title, "TitleOn", "visible")
	UpdateValues(RichText, "Note", "text")
	User.connect("PreviewNotes", Callable(self, "PreviewNotes"))

func UpdateValues(NODE, value, parameter):
	if Data.has(value):
		NODE.call_deferred("set", parameter, Data[value])

func GetData():
	return Data

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

func EditNotes():
	$Preview.visible = !Editing
	$ScrollContainer.visible = Editing

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
	EditNotes()

func _on_text_focus_entered() -> void:
	Editing = true
	EditNotes()

func PreviewNotes():
	if User.PreviewingNotes:
		RichText.mouse_filter = MOUSE_FILTER_STOP
	else :
		RichText.mouse_filter = MOUSE_FILTER_IGNORE

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
