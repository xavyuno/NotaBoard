extends TabContainer

func _ready() -> void :
	User.connect("ChangeBoard", Callable(self, "ChangeBoard"))
	User.connect("SaveObjectData", Callable(self, "saveItems"))
	User.connect("ForceUpdateID", Callable(self, "ForceUpdateID"))
	var userArg = OS.get_cmdline_user_args()
	for i in userArg:
		var filteredCMD = i.to_lower().replace("-", "")
		if filteredCMD == "test":
			User.TestingMode = true

func ForceUpdateID():
	Settings.Data["TotalItems"] = 0
	for i in get_children():
		if !i.is_in_group("NoCanvas"):
			for j in i.get_children():
				if j.is_in_group("Item"):
					Settings.Data["TotalItems"] += 1
					j.Data["ItemID"] = Settings.Data["TotalItems"]

func _exit_tree() -> void :
	saveItems()

func saveItems():
	if User.StillLoading:
		return
	User.StoredHistory = []
	for i in get_children(true):

		if i.name.similarity("Settings") < 1:
			if i.has_method("GetData"):

				User.StoredHistory.append(i.GetData())
			for j in i.get_children(true):

				if j.has_method("GetData"):

					User.StoredHistory.append(j.GetData())

func ChangeBoard(Board: String, Title: String, _ID = "", _CamPos = Vector2(640, 352), _CamZoom = 1):
	var Found = false
	for i in get_tab_count():
		if get_tab_control(i).name == Board:
			current_tab = i
			Settings.Data["CurrentPage"] = Board
			Settings.Data["PageTitle"] = Title
			Found = true

	if !Found:
		var NewBoard = preload("res://App/Assets/Scenes/NewBoard/NewBoard.tscn").instantiate()
		NewBoard.name = Board
		get_parent().get_node("Boards/").add_child(NewBoard)
		current_tab = get_tab_count() - 1

		Settings.Data["CurrentPage"] = Board
		Settings.Data["PageTitle"] = Title
