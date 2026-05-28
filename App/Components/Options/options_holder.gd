extends HBoxContainer

@export var MainObject = get_parent()
@export var IncludeMove: = true
@export var IncludeClose: = true
@export var IncludeRatio: = true

func _ready() -> void :
	$Move.par = MainObject
	$Close.par = MainObject
	$Ratio.par = MainObject

	$Move.visible = IncludeMove
	$Close.visible = IncludeClose
	$Ratio.visible = IncludeRatio
