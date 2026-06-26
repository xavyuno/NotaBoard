extends Button

var Day := 1
var Month := 1
var Year := 1
var Empty := false

func _ready() -> void:
	if Empty:
		$Title.visible = false
		disabled = true
		return
	if Time.get_datetime_dict_from_system()["day"] == (Day) and Time.get_datetime_dict_from_system()["month"] == Month and Time.get_datetime_dict_from_system()["year"] == Year:
		$BG.visible = true
	$Title.text = str(Day)
