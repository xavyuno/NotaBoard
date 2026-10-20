extends Item

var Data: = {
	"Type": "Link", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"Link": "", 
	"ID": "Home",
	"Thumbnail" : null,
	"ThumbnailPath" : "",
	"ItemID" : "",
	"Tags" : [],
	"Styles" : ""
}

var Options := [
	"Thumbnail",
	"GoTo",
	"Link"
]

func _ready() -> void :
	initItem()
	ApplyData()

func ApplyData():
	UpdateValues($Access/Image, "Thumbnail", "texture")
	if Data.has("Thumbnail"):
		if Data["Thumbnail"] == null:
			$GetPreview.request("https://api.linkpreview.net/?q=" + Data["Link"], ["X-Linkpreview-Api-Key: " + Settings.Data["UrlAPIKey"]])
			$Access.text = "Link Item.\nClick for options."
		else :
			$Access/Image.visible = true
	else:
		$Access.text = "Link Item.\nClick for options."
		$GetPreview.request("https://api.linkpreview.net/?q=" + Data["Link"], ["X-Linkpreview-Api-Key: " + Settings.Data["UrlAPIKey"]])


func GetImage():
	if GetThumbnailPath():
		Data.merge({"ThumbnailPath" : ""}, true)
		DirAccess.make_dir_absolute("user://SavedLinkImages")
		var files = DirAccess.get_files_at("user://SavedLinkImages")
		var filepath
		if files.size() > 0:
			filepath = "user://SavedLinkImages/" + str( int(files.size()) + 1 ) + ".png"
		else :
			filepath = "user://SavedLinkImages/1.png"
		$Access/Image.texture.get_image().save_png(filepath)
		Data["ThumbnailPath"] = filepath
		$Access.text = ""
		return filepath
	else :
		if $Access/Image.texture and Data["ThumbnailPath"] != "":
			$Access/Image.texture.get_image().save_png(Data["ThumbnailPath"])
			$Access.text = ""
			return Data["ThumbnailPath"]
		else:
			$Access.text = "Link Item.\nClick for options."
			return ""

func GetThumbnailPath():
	if Data.has("ThumbnailPath"):
		if Data["ThumbnailPath"] == "":
			return false
		else:
			return true
	else:
		return false

func _process(_delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size

func _on_go_to_pressed() -> void :
	OS.shell_open($Holder / Link.text)

func SetLink(text):
	$GetLink.request(text)
	Data["Link"] = text

func _on_get_link_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	var img = Image.new()
	var errJPG = img.load_jpg_from_buffer(body)
	if errJPG != OK:
		var errPNG = img.load_png_from_buffer(body)
		if errPNG != OK:
			$GetPreview.request("https://api.linkpreview.net/?q=" + Data["Link"], ["X-Linkpreview-Api-Key: " + Settings.Data["UrlAPIKey"]])
			print("failed to get thumbnail")
			$Access.text = "Link Item.\nClick for options."
			return
	$Access/Image.visible = true
	var txtr = ImageTexture.create_from_image(img)
	$Access/Image.texture = txtr
	GetImage()
	Data["Thumbnail"] = txtr

func _on_get_preview_request_completed(_result: int, _response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var link = JSON.parse_string(body.get_string_from_utf8())
	if link is Dictionary:
		if link["image"] != "":
			$GetLink.request(link["image"])
			$Access.text = "Link Item.\nClick for options."
	else :
		$Access.text = "Link Item.\nClick for options."
		print("failed to get LINK")
