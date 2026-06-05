extends Node

signal SettingsChanged

var BackgroundCol: = Color.ROYAL_BLUE
var UpdatePath: String = "user://TaskManager.exe"
var ItemLimit := 10000

func GetSettings():
	return [
		BackgroundCol, 
		UpdatePath,
		User.LoadDur,
		ItemLimit,
	]
