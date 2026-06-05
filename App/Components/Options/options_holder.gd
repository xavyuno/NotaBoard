extends HBoxContainer

@export var Par = get_parent()
@export var IncludeMove: = true
@export var IncludeClose: = true
@export var IncludeRatio: = true

func _ready() -> void :
	User.TotalItems += 1
	$Move.par = Par
	$Close.par = Par
	$Ratio.par = Par

	$Move.visible = IncludeMove
	$Close.visible = IncludeClose
	$Ratio.visible = IncludeRatio
