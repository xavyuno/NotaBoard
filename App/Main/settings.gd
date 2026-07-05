extends Control

@onready var progress: TextureProgressBar = $Update / Progress
@onready var info: Label = $Update / Info
@onready var download: HTTPRequest = $Update / Download

var Downloading: = false
var Version: = ""

func _ready() -> void :
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))
	var ver = FileAccess.open("res://LatestVersion.txt", FileAccess.READ).get_as_text()
	ver = ver.strip_edges(true, true)
	ver = ver.strip_escapes()
	$Version.text = "Version: " + ver.validate_filename()
	var file = FileAccess.open("res://Updates.txt", FileAccess.READ)
	$Changelog/ScrollContainer/Notes.text = file.get_as_text()
	file.close()


func _physics_process(delta: float) -> void :
	if Downloading:
		$Update / Progress.value = download.get_downloaded_bytes()
		$Update / Info.text = "Downloading Update..."
		$Update / Version.text = Version
	$Update / Version.visible = Downloading
	$TotalItems.text = "Total Items: " + str(User.TotalItems) + " / " + str(Settings.ItemLimit)
	$PreviewNotes.text = "Previewing Notes: On" if User.PreviewingNotes else "Previewing Notes: Off"

func SettingsChanged():
	$BGPicker.color = Settings.BackgroundCol
	$LoadDur.value = Settings.LoadDur
	$ItemLimit.value = Settings.ItemLimit
	$Center.text = "Show Center: On" if Settings.ShowCenter else "Show Center: Off"
	$Center.alignment = HORIZONTAL_ALIGNMENT_CENTER if Settings.ShowCenter else HORIZONTAL_ALIGNMENT_LEFT
	$ShowBar.text = "Show options bar: On" if Settings.OptionsEnabled else "Show options bar: Off"
	$Proload.text = "On" if Settings.ProgressiveLoading else "Off"
	$DefaultFontSize.value = Settings.DefaultFontSize
	$DefaultTitle.value = Settings.DefaultTtileSize
	$TotalBoards.text = "Total Boards: " + str(Settings.TotalBoards)

func _on_color_picker_button_color_changed(color: Color) -> void :
	Settings.BackgroundCol = color
	Settings.emit_signal("SettingsChanged")

func _on_project_dir_pressed() -> void :
	OS.shell_open(ProjectSettings.globalize_path("user://"))

func _on_project_link_pressed() -> void :
	OS.shell_open("https://github.com/xavyuno/Task-Manager")

func _on_update_pressed() -> void :
	$Update / FileDialog.current_path = Settings.UpdatePath
	$Update / FileDialog.popup(Rect2i(600, 600, 600, 600))

func _on_download_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void :
	Downloading = false
	$Update / Info.text = "Update Finished!"
	print("Retrieved Data")
	if response_code == 200:
		var file = FileAccess.open(Settings.UpdatePath, FileAccess.WRITE)
		file.store_buffer(body)
		file.close()
		print("Update successful")
	else:
		print("Failed to get update")
	await get_tree().create_timer(1).timeout
	$Update / Info.text = "Download Update"

func _on_get_version_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void :
	if response_code == 200:
		Version = body.get_string_from_utf8()
		if Version == FileAccess.open("res://LatestVersion.txt", FileAccess.READ).get_as_text():
			$Update / Info.text = "Already Up-to-date!"
			await get_tree().create_timer(1).timeout
			$Update / Info.text = "Download Update"
			return
		if !Version.is_empty():
			$Update / Info.text = "Recieved Latest Version!"
			print("Retrieved version: " + Version)
			var url = "https://github.com/xavyuno/Task-Manager/releases/download/%s/TaskManager.exe" % Version.strip_escapes()
			print("url: " + url)
			download.request(url)
			Downloading = true
	else:
		print("Failed to get version")

func _on_file_dialog_file_selected(path: String) -> void :
	$Update / Info.text = "Getting Latest Version"
	Settings.UpdatePath = path
	$Update / GetVersion.request("https://raw.githubusercontent.com/xavyuno/Task-Manager/main/LatestVersion.txt")


func _on_notes_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

func _on_load_dur_value_changed(value: float) -> void:
	Settings.LoadDur = value

func _on_submit_feedback_pressed() -> void:
	if $Feedback.text == "":
		return
	var req := $SubmitFeedback/SubmitReq
	req.request(System.GetAPI(0), ["Content-type: application/json"], HTTPClient.METHOD_POST, JSON.stringify({"content" : "```\n" + $Feedback.text + "\n```"}))

func _on_submit_req_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		print(body.get_string_from_utf8())
	else :
		print("failed to submit feedback")

func _on_item_limit_value_changed(value: float) -> void:
	Settings.ItemLimit = value

func _on_center_pressed() -> void:
	Settings.ShowCenter = !Settings.ShowCenter
	Settings.emit_signal("SettingsChanged")

func _on_preview_notes_pressed() -> void:
	User.PreviewingNotes = !User.PreviewingNotes

func _on_show_bar_pressed() -> void:
	Settings.OptionsEnabled = !Settings.OptionsEnabled
	Settings.emit_signal("SettingsChanged")

func _on_default_font_size_value_changed(value: float) -> void:
	Settings.DefaultFontSize = int(value)
	Settings.emit_signal("SettingsChanged")

func _on_default_title_value_changed(value: float) -> void:
	Settings.DefaultTtileSize = int(value)
	Settings.emit_signal("SettingsChanged")


func _on_calendar_pressed() -> void:
	User.emit_signal("ChangeBoard", "Calendar", "Calendar", "", User.CamPosCalendar)

func _on_proload_pressed() -> void:
	Settings.ProgressiveLoading
	Settings.emit_signal("SettingsChanged")
