extends VBoxContainer

var Data: = {
	"Type": "Link", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"Link": "", 
	"ID": "Home",
	"Thumbnail" : null
}

var Options := []

func _ready() -> void :
	UpdateValues($Holder / Link, "Link", "text")
	UpdateValues($Image, "Thumbnail", "texture")
	if Data.has("Thumbnail"):
		if Data["Thumbnail"] == null:
			$GetLink.request(Data["Link"])
		else :
			$Image.visible = true
	else:
		$GetLink.request(Data["Link"])

func UpdateValues(NODE, value, parameter):
	if Data.has(value):
		NODE.call_deferred("set", parameter, Data[value])

func GetData():
	return Data

func _process(delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size
	Data["Link"] = $Holder / Link.text

func _on_go_to_pressed() -> void :
	OS.shell_open($Holder / Link.text)

func _on_link_text_submitted(new_text: String) -> void :
	$Image.visible = false
	$GetLink.request($Holder / Link.text)

func _on_get_link_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void :
	var img = Image.new()
	var errJPG = img.load_jpg_from_buffer(body)
	if errJPG != OK:
		var errPNG = img.load_png_from_buffer(body)
		if errPNG != OK:
			$Image.visible = false
			$GetPreview.request("https://api.linkpreview.net/?q=" + Data["Link"], ["X-Linkpreview-Api-Key: " + Settings.UrlAPIKey])
			return
	$GetPreview.cancel_request()
	$Image.visible = true
	var txtr = ImageTexture.create_from_image(img)
	$Image.texture = txtr
	Data["Thumbnail"] = txtr

func _on_link_focus_exited() -> void :
	$GetLink.request($Holder / Link.text)

func _on_get_preview_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var link = JSON.parse_string(body.get_string_from_utf8())
	if link:
		$GetLink.request(link["image"])
	else :
		print("failed to get thumbnail")
