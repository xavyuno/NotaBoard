extends VBoxContainer

var Data: = {
	"Type": "Link", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"Link": "", 
	"ID": "Home"
}

func _ready() -> void :
	UpdateValues($Holder / Link, "Link", "text")
	if Data["Link"].begins_with("Https") or Data["Link"].ends_with(".com"):
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
	$GetLink.request($Holder / Link.text)

func _on_get_link_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void :
	var img = Image.new()
	var errJPG = img.load_jpg_from_buffer(body)
	if errJPG != OK:
		var errPNG = img.load_png_from_buffer(body)
		if errPNG != OK:
			$Image.visible = false
			return
	$Image.visible = true
	var txtr = ImageTexture.create_from_image(img)
	$Image.texture = txtr

func _on_link_focus_exited() -> void :
	$GetLink.request($Holder / Link.text)
