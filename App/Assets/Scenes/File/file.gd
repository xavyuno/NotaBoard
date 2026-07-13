extends Item

var Data: = {
	"Type": "File", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"ID": "Home", 
	"Dir": "",
	"DirVisible" : false
}

var Options := [
	"Dir",
	"Ratio",
	"Open"
]

func _ready() -> void :
	initItem()
	UpdateValues($DirHolder / FileName, "Dir", "text")
	#UpdateValues($DirHolder, "DirVisible", "visible")
	LoadFile()

func _process(delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size
	Data["DirVisible"] = $DirHolder.visible

func _on_file_dialog_file_selected(path: String) -> void :
	$DirHolder / FileName.text = path
	Data["Dir"] = path
	LoadFile()

func LoadFile():
	if Data["Dir"] == "":
		return
	var img = Image.load_from_file(ProjectSettings.globalize_path(Data["Dir"]))
	var imgTxt = ImageTexture.new()
	var texture
	if img:
		texture = imgTxt.create_from_image(img)
	if texture is Texture:
		$Open / Image.texture = texture
		$Open / Holder.visible = false
		$Open / Title.text = ""
	else:
		$Open / Image.texture = null
		$Open / Title.text = "Open"
		$Open / Holder.visible = true
		var file = FileAccess.open(ProjectSettings.globalize_path(Data["Dir"]), FileAccess.READ)
		var txt
		if file:
			txt = file.get_as_text()
			$Open / Holder / Preview.text = "Preview:\n" + txt
			file.close()
	size = Data["Size"]

func _on_dir_pressed() -> void :
	var dirarray: Array = Data["Dir"].split("/")
	$FileDialog.current_dir = Data["Dir"].trim_suffix(dirarray[dirarray.size() - 1])
	$FileDialog.popup(Rect2(0, 0, 600, 600))


func _on_open_pressed() -> void:
	#OS.shell_open(ProjectSettings.globalize_path($DirHolder/FileName.text))
	pass

func _on_directory_pressed() -> void:
	$DirHolder.visible = !$DirHolder.visible
