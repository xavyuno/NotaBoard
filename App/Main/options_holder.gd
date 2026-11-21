extends ScrollContainer

var Options := []
var popupConst = null

func _ready() -> void:
	User.connect("ItemFocused", Callable(self, "ItemFocused"))
	User.connect("ItemFocusLost", Callable(self, "ItemFocusLost"))
	visible = false

func DeletePressed():
	for i in User.MultiSelectedObjects.keys():
		for j in User.MultiSelectedObjects[i]:
			get_node(j).Delete()

func RatioPressed():
	for i in User.MultiSelectedObjects.keys():
		for j in User.MultiSelectedObjects[i]:
			var Lowest: float = get_node(j).size.x
			if get_node(j).size.y < Lowest:
				Lowest = get_node(j).size.y
			get_node(j).size = Vector2(Lowest, Lowest)

func TitlePressed():
	for i in System.GetItemFromList(["Notes", "ToDo"]):
		if get_node(i).has_node("Title"):
			get_node(i).get_node("Title").visible = !get_node(i).get_node("Title").visible
		else :
			get_node(i).get_node("Top/Title").visible = !get_node(i).get_node("Top/Title").visible
		Customization.emit_signal("ApplyCustomization")

func NotePressed():
	for i in System.GetItemFromList(["Notes"]):
		get_node(i).get_node("Preview").visible = !get_node(i).get_node("Preview").visible

func DirectoryPressed():
	for i in System.GetItemFromList(["Notes"]):
		var dirarray: Array = get_node(i).Data["Dir"].split("/")
		$"../../FileDialog".current_dir = get_node(i).Data["Dir"].trim_suffix(dirarray[dirarray.size() - 1])
		$"../../FileDialog".popup(Rect2(0, 0, 600, 600))

func CoverPressed():
	var Filedia := FileDialog.new()
	Filedia.connect("file_selected", Callable(self, "popup"))
	Filedia.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	Filedia.access = FileDialog.ACCESS_FILESYSTEM
	for i in ["png", "jpeg"]:
		Filedia.add_filter("*." + i)
	get_tree().root.add_child(Filedia)
	Filedia.popup(Rect2i(500, 500, 600, 600))
	popupConst = Filedia

func OpenPressed():
	for i in System.GetItemFromList(["File"]):
		OS.shell_open(ProjectSettings.globalize_path(get_node(i).Data["Dir"]))

func popup(path):
	for i in System.GetItemFromList(["Board"]):
		var img = Image.load_from_file(ProjectSettings.globalize_path(path))
		var imgtxt = ImageTexture.create_from_image(img)
		get_node(i).ChangeCover(imgtxt)
		popupConst.queue_free()

func ItemFocusLost():
	if get_node("../../../../Boards/" + Settings.Data["CurrentPage"]).is_in_group("NoCanvas"):
		$"../ItemHolder".visible = false
		visible = false
	else:
		$"../ItemHolder".visible = true
		visible = false

func MovePressed():
	User.ShowMoveButton = !User.ShowMoveButton

func ItemFocused(path : NodePath):
	if get_node("../../../../Boards/" + Settings.Data["CurrentPage"]).is_in_group("NoCanvas"):
		$"../ItemHolder".visible = false
		visible = false
	else:
		$"../ItemHolder".visible = false
		visible = true
	
	Options = []
	for i in User.MultiSelectedObjects.keys():
		for j in User.MultiSelectedObjects[i]:
				Options.append_array(get_node(j).Options)
	if Options.size() <= 0:
		return
	for i in $Items.get_children():
		if !i.name in ["ItemID", "ID", "Tags", "SelectStyle"]: 
			i.visible = false
	for i in Options.size():
		if !$Items.get_node_or_null(Options[i]):
			var but = Button.new()
			but.name = Options[i]
			but.text = Options[i]
			$Items.get_child(0).add_sibling(but)
			but.connect("pressed", Callable(self, but.name + "Pressed"))
			but.tooltip_text = but.name
		else:
			$Items.get_node(Options[i]).visible = true
	
	#Select style
	$Items/SelectStyle/Style.clear()
	var id = 0
	var options = Customization.Themes.keys()
	options.append("None")
	for i in options:
		$Items/SelectStyle/Style.add_item(i)
		if get_node(path).Data["Style"] is String:
			if i == get_node(path).Data["Style"]:
				$Items/SelectStyle/Style.select(id)
		id += 1
	$Items/Tags/Options/Input.text = ""
	ValidateValue($Items/ID, "ID", "text", GetValue("ID: ", "ID"))
	ValidateValue($Items/ItemID, "ItemID", "text", GetValue("Item ID: ", "ItemID"))
	ValidateValue($Items/Board, "Board", "value", GetValue("", "Board"))
	ValidateValue($Items/FontSize, "FontSize", "value", GetValue("", "FontSize"))
	ValidateValue($Items/TitleSize, "TitleSize", "value", GetValue("", "TitleSize"))
	ValidateValue($Items/Link, "Link", "text", GetValue("", "Link"))
	ValidateValue($Items/BoardName, "Title", "text", GetValue("", "Title"))
	ReloadTags()
	
func ReloadTags():
	if $Items/Tags/Holder.get_child_count() >= 1:
		for i in $Items/Tags/Holder.get_children():
			i.queue_free()
	var TotalTags = 0
	for a in User.MultiSelectedObjects.keys():
		for j in User.MultiSelectedObjects[a]:
			for i in get_node(j).Data["Tags"]:
				var butt = Button.new()
				butt.text = i
				butt.name = i
				butt.tooltip_text = "Click to remove tag"
				butt.connect("pressed", RemoveTag.bind(TotalTags, i))
				$Items/Tags/Holder.add_child(butt)
				TotalTags += 1

func RemoveTag(ID, Tag):
	for i in User.MultiSelectedObjects.keys():
		for j in User.MultiSelectedObjects[i]:
			get_node(j).Data["Tags"].remove_at(ID)
			get_node("Items/Tags/Holder/" + Tag).queue_free()

func GetValue(before, parameter, after = ""):
	for i in User.MultiSelectedObjects.keys():
		for j in User.MultiSelectedObjects[i]:
			if get_node(j).Data.has(parameter):
				if before == "" and after == "":
					return get_node(j).Data[parameter]
				else :
					return before + str(get_node(j).Data[parameter]) + after
			else :
				return ""

func CapturePressed():
	for i in System.GetItemFromList(["Canvas"]):
		get_node(i).Capture()

func ClearPressed():
	for i in System.GetItemFromList(["Canvas"]):
		get_node(i).Clear()

func ThumbnailPressed():
	for i in System.GetItemFromList(["Link"]):
		OS.shell_open(ProjectSettings.globalize_path(get_node(i).GetImage()))

func GoToPressed():
	for i in System.GetItemFromList(["Link"]):
		OS.shell_open(get_node(i).Data["Link"])

func ProgressPressed():
	for i in System.GetItemFromList(["ToDo"]):
		get_node(i).get_node("Top/Progress").visible = !get_node(i).get_node("Top/Progress").visible

func ValidateValue(Nodepath, value, parameter, change = ""):
	change = str(change)
	for i in User.MultiSelectedObjects.keys():
		for j in User.MultiSelectedObjects[i]:
			if get_node(j).Data.has(value):
				if change == "":
					Nodepath.set(parameter, get_node(j).Data[value])
				else :
					Nodepath.set(parameter, change)

func _on_board_value_changed(value: float) -> void:
	for i in System.GetItemFromList(["Board"]):
		get_node(i).ChangeID(value)

func _on_font_size_value_changed(value: float) -> void:
	for i in System.GetItemFromList(["Notes", "ToDo"]):
		get_node(i).ChangeFontSize(value)

func _on_title_size_value_changed(value: float) -> void:
	for i in System.GetItemFromList(["Notes", "ToDo"]):
		get_node(i).ChangeTitleSize(value)

func _on_file_dialog_file_selected(path: String) -> void:
	for i in System.GetItemFromList(["File"]):
		get_node(i).Data["Dir"] = path
		get_node(i).LoadFile()

func _on_link_focus_exited() -> void:
	for i in System.GetItemFromList(["Link"]):
		get_node(i).SetLink($Items/Link.text)

func _on_board_name_text_changed(new_text: String) -> void:
	for i in System.GetItemFromList(["Board"]):
		get_node(i).SetTitle(new_text)

func _on_add_pressed() -> void:
	for i in User.MultiSelectedObjects.keys():
		for j in User.MultiSelectedObjects[i]:
			get_node(j).AddTag($Items/Tags/Options/Input.text)
			ReloadTags()

func AutoExpandPressed():
	for i in System.GetItemFromList(["Notes"]):
		get_node(i).get_node("Text").fit_content = !get_node(i).get_node("Text").fit_content


func _on_style_item_selected(index: int) -> void:
	for i in User.MultiSelectedObjects.keys():
		for j in User.MultiSelectedObjects[i]:
			get_node(j).Data["Style"] = $Items/SelectStyle/Style.get_item_text(index)
			get_node(j).CreateStyle()
