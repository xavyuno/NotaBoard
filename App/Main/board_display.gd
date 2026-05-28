extends HBoxContainer

func _ready() -> void :
	User.connect("ChangeBoard", Callable(self, "ChangedBoard"))

func _on_button_pressed() -> void :
	User.emit_signal("ChangeBoard", "Home", "Home")

func ChangedBoard(Board: String, Title: String):
	$NewBoard.text = User.PreviousTitle
	if Board.similarity("Home") == 1:
		$NewBoard.visible = false
		$Home.visible = false
	else:
		$Home.visible = true
		var tempTitle = Title
		if tempTitle.is_empty():
			tempTitle = "Untitled Board"
		$NewBoard.text = tempTitle
		$NewBoard.visible = true

func _on_new_board_pressed() -> void :
	User.emit_signal("ChangeBoard", User.PreviousPage, User.PreviousTitle)
