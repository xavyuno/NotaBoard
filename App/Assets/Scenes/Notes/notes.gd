@tool
extends VBoxContainer

@export var Options: = true
@export var Expand: = true
@export var CloseButton: = true
@export var MoveButton: = true
@export var TitleOn: = true
@export var Title: = ""
@export var CanEdit: = true
@export var UseData: = true
@export_multiline var Text: = ""

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

func _ready() -> void :
    if UseData:
        UpdateValues($ScrollContainer / Notes, "Note", "text")
        UpdateValues($ScrollContainer, "NoteOn", "visible")
        UpdateValues($Title, "Title", "text")
        UpdateValues($Title, "TitleOn", "visible")
    Elements()

func UpdateValues(NODE, value, parameter):
    if Data.has(value):
        NODE.call_deferred("set", parameter, Data[value])

func Elements():
    $OptionsHolder / Close.visible = CloseButton
    $OptionsHolder / Move.visible = MoveButton
    $OptionsHolder.visible = Options
    $ExpandHolder.visible = Expand
    if !Text.is_empty():
        $ScrollContainer / Notes.text = Text
    if !Title.is_empty():
        $Title.text = Title
        $Title.visible = TitleOn
    $ScrollContainer / Notes.editable = CanEdit

func GetData():
    return Data

func _process(delta: float) -> void :
    Data["Pos"] = position
    Data["Size"] = size
    Data["Note"] = $ScrollContainer / Notes.text
    Data["Title"] = $Title.text
    Data["TitleOn"] = $Title.visible
    Data["NoteOn"] = $ScrollContainer.visible
    if Engine.is_editor_hint():
        Elements()

func ExtraUI(view: bool):
    $OptionsHolder.visible = view
    $ExpandHolder.visible = view

func _on_title_on_pressed() -> void :
    $Title.visible = !$Title.visible

func _on_note_on_pressed() -> void :
    $ScrollContainer.visible = !$ScrollContainer.visible
