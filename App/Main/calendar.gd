extends Control

const MONTH_DAYS = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]

var Dates :=[
	"Januray",
	"Febraury",
	"March",
	"April",
	"May",
	"June",
	"July",
	"August",
	"September",
	"November",
	"December"
]

var WeekDays := ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

func _ready() -> void:
	$Main/Year.value = Time.get_datetime_dict_from_system()["year"]
	for i in Dates:
		$Main/Month.add_item(i)
	$Main/Month.select(Time.get_datetime_dict_from_system()["month"]-1)
	CreateCalendar(Time.get_datetime_dict_from_system()["month"], Time.get_datetime_dict_from_system()["year"])

func CreateCalendar(specificMonth, year):
	for i in $Frame/Holder.get_children():
		i.queue_free()
	var unixDate := Time.get_datetime_dict_from_system()
	unixDate["month"] = specificMonth
	unixDate["day"] = 1
	unixDate["year"] = year
	var StartingDay = Time.get_datetime_dict_from_unix_time(
			Time.get_unix_time_from_datetime_dict(unixDate)
		)["weekday"]
	if StartingDay >= 1:
		for i in StartingDay:
			var day = preload("res://App/Components/Day/day.tscn").instantiate()
			day.Empty = true
			$Frame/Holder.add_child(day)
	for i in MONTH_DAYS[specificMonth-1]:
		var day = preload("res://App/Components/Day/day.tscn").instantiate()
		day.Day = i+1
		day.Year = year
		day.Month = specificMonth
		$Frame/Holder.add_child(day)

func _on_month_item_selected(index: int) -> void:
	CreateCalendar(index+1, Time.get_datetime_dict_from_system()["year"])

func _on_year_value_changed(value: float) -> void:
	CreateCalendar(Time.get_datetime_dict_from_system()["month"], int(value))
