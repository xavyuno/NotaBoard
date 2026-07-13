extends Button

var Day := 1
var Month := 1
var Year := 1
var Empty := false

func _ready() -> void:
	if Empty:
		$MainHolder/Title.visible = false
		disabled = true
		return
	if Time.get_datetime_dict_from_system()["day"] == (Day) and Time.get_datetime_dict_from_system()["month"] == Month and Time.get_datetime_dict_from_system()["year"] == Year:
		$BG.visible = true
	$MainHolder/Title.text = str(Day)
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))

func SettingsChanged():
	for i in $Scroll/Holder.get_children():
		i.queue_free()
	if !User.SavedEvents.has(System.DateToString([Day, Month, Year])):
		$MainHolder/TotalEvents.visible = false
		return
	else :
		for i in User.SavedEvents[System.DateToString([Day, Month, Year])].size():
			var info = Label.new()
			info.text = User.SavedEvents[System.DateToString([Day, Month, Year])][i]
			info.add_theme_font_size_override("font_size", 12)
			$Scroll/Holder.add_child(info)
		if $MainHolder.get_child_count() >= 1:
			$MainHolder/TotalEvents.visible = true
			$MainHolder/TotalEvents.text = str(User.SavedEvents[System.DateToString([Day, Month, Year])].size())
		else :
			$MainHolder/TotalEvents.visible = false


func _on_pressed() -> void:
	User.SelectedDate = [Day, Month, Year]
	Settings.emit_signal("SettingsChanged")
