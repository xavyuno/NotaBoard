extends VBoxContainer

var Data: = {
	"Type": "Link", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"Link": "", 
	"ID": "Home",
	"Thumbnail" : null,
	"ThumbnailPath" : ""
}

var Options := [
	"Thumbnail",
	"GoTo",
	"Link"
]

func _ready() -> void :
	UpdateValues($Access/Image, "Thumbnail", "texture")
	if Data.has("Thumbnail"):
		if Data["Thumbnail"] == null:
			$GetPreview.request(Data["Link"])
		else :
			$Access/Image.visible = true
	else:
		$GetPreview.request(Data["Link"])

func UpdateValues(NODE, value, parameter):
	if Data.has(value):
		NODE.call_deferred("set", parameter, Data[value])

func GetData():
	return Data

func GetImage():
	if !Data.has("ThumbnailPath"):
		Data.merge({"ThumbnailPath" : ""}, true)
		var Dir = DirAccess.make_dir_absolute("user://SavedLinkImages")
		var files = DirAccess.get_files_at("user://SavedLinkImages")
		var filepath
		if files.size() > 0:
			filepath = "user://SavedLinkImages/" + str( int(files.size()) + 1 ) + ".png"
		else :
			filepath = "user://SavedLinkImages/1.png"
		$Access/Image.texture.get_image().save_png(filepath)
		Data["ThumbnailPath"] = filepath
		return filepath
	else :
		$Access/Image.texture.get_image().save_png(Data["ThumbnailPath"])
		return Data["ThumbnailPath"]

func _process(delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size

func _on_go_to_pressed() -> void :
	OS.shell_open($Holder / Link.text)

func SetLink(text):
	$GetPreview.request(text)
	Data["Link"] = text

func _on_get_link_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void :
	var img = Image.new()
	var errJPG = img.load_jpg_from_buffer(body)
	if errJPG != OK:
		var errPNG = img.load_png_from_buffer(body)
		if errPNG != OK:
			$Access/Image.visible = false
			$GetPreview.request("https://api.linkpreview.net/?q=" + Data["Link"], ["X-Linkpreview-Api-Key: " + Settings.UrlAPIKey])
			return
	$GetPreview.cancel_request()
	$Access/Image.visible = true
	var txtr = ImageTexture.create_from_image(img)
	$Access/Image.texture = txtr
	GetImage()
	Data["Thumbnail"] = txtr

func _on_link_focus_exited() -> void :
	$GetLink.request($Holder / Link.text)

func _on_get_preview_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var link = JSON.parse_string(body.get_string_from_utf8())
	if link:
		$GetLink.request(link["image"])
	else :
		print("failed to get thumbnail")
