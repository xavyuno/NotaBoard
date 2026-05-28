extends VBoxContainer

var Data: = {
	"Type": "File", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"ID": "Home", 
	"Dir": "", 
}

func _ready() -> void :
	UpdateValues($DirHolder / FileName, "Dir", "text")
	LoadFile()

func UpdateValues(NODE, value, parameter):
	if Data.has(value):
		NODE.call_deferred("set", parameter, Data[value])

func GetData():
	return Data

func _process(delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size

func _on_new_pressed() -> void :
	OS.shell_open($DirHolder / FileName.text)

func _on_file_dialog_file_selected(path: String) -> void :
	$DirHolder / FileName.text = path
	Data["Dir"] = path
	LoadFile()

func LoadFile():
	if Data["Dir"] == "":
		return
	var img = Image.load_from_file(ProjectSettings.globalize_path(Data["Dir"]))
	var imgTxt = ImageTexture.new()
	var texture = imgTxt.create_from_image(img)
	if texture is Texture:
		$Open / Image.texture = texture
		$Open / Holder.visible = false
		$Open / Title.text = ""
	else:
		$Open / Image.texture = null
		$Open / Title.text = "Open"
		$Open / Holder.visible = true
		var file = FileAccess.open(ProjectSettings.globalize_path(Data["Dir"]), FileAccess.READ)
		var txt = file.get_as_text()
		file.close()
		$Open / Holder / Preview.text = "Preview:\n" + txt
	size = Data["Size"]

func _on_dir_pressed() -> void :
	var dirarray: Array = Data["Dir"].split("/")
	$FileDialog.current_dir = Data["Dir"].trim_suffix(dirarray[dirarray.size() - 1])
	$FileDialog.popup(Rect2(0, 0, 600, 600))
