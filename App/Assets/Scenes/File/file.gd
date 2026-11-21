extends Item

var Data: = {
	"Type": "File", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"ID": "Home", 
	"Dir": "",
	"CachedImage" : null,
	"ItemID" : -1,
	"Tags" : [],
	"Style" : ""
}

var Options := [
	"Directory",
	"Ratio",
	"Open"
]

func _ready() -> void :
	initItem()
	ApplyData()

func ApplyData():
	LoadFile()

func _process(_delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size
	Data["CachedImage"] = $Open/Image.texture

func LoadFile():
	if Data["Dir"] == "":
		return
	var ImageExtensions = ["bmp", "dds", "exr", "hdr", "jpg", "jpeg", "png", "tga", "svg", "svgz", "webp"]
	if Data["Dir"].split(".")[1] in ImageExtensions:
		var img = Image.load_from_file(ProjectSettings.globalize_path(Data["Dir"]))
		var texture
		if img:
			texture = ImageTexture.create_from_image(img)
		else:
			texture = Has("CachedImage")
		if texture:
			$Open / Image.texture = texture
			$Open / Holder.visible = false
			$Open / Title.text = ""
		else:
			LoadTextContents()
	else:
		LoadTextContents()

func LoadTextContents():
		print("1")
		$Open / Image.texture = null
		$Open / Title.text = "Click to view options"
		$Open / Holder.visible = true
		var file = FileAccess.open(ProjectSettings.globalize_path(Data["Dir"]), FileAccess.READ)
		print(file.get_as_text())
		if file:
			$Open / Holder / Preview.text = file.get_as_text()
			file.close()
