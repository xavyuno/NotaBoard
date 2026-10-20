extends Button

var Downloading: = false
var Version = ""

func _ready() -> void:
	visible = false
	$GetVersion.request("https://raw.githubusercontent.com/xavyuno/Task-Manager/main/LatestVersion.txt")

func _process(_delta: float) -> void:
	if Downloading:
		$Progress.value = $Download.get_downloaded_bytes()
		text = "Downloading Update..."
		$Version.text = str(Version)
	$Version.visible = Downloading

func _on_get_version_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	if response_code == 200:
		Version = body.get_string_from_utf8().trim_prefix("v").to_float()
		var OwnedVer = FileAccess.open("res://LatestVersion.txt", FileAccess.READ).get_as_text().trim_prefix("v").to_float()
		if Version <= OwnedVer:
			return
		else :
			visible = true
			System.CreateNotif("New update: " + Version)
			var url = "https://github.com/xavyuno/NotaBoard/releases/download/v%s/NotaBoard.exe" % str(Version)
			$Download.request(url)
			Downloading = true
	else:
		System.CreateNotif("Failed to find newest version.", true)

func _on_download_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	Downloading = false
	if response_code == 200:
		var file = FileAccess.open(Settings.Data["UpdatePath"], FileAccess.WRITE)
		file.store_buffer(body)
		file.close()
		System.CreateNotif("Update Successful!")
		visible = false
	else:
		System.CreateNotif("Failed to install update to location | Error: " + str(response_code), true)
	await get_tree().create_timer(1).timeout

func _on_pressed() -> void:
	$FileDialog.current_path = Settings.Data["UpdatePath"]
	$FileDialog.popup(Rect2i(600, 600, 600, 600))

func _on_file_dialog_file_selected(path: String) -> void:
	Settings.Data["UpdatePath"] = path
