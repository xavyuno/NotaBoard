extends Node

signal SettingsChanged

var BackgroundCol: = Color.ROYAL_BLUE
var UpdatePath: String = "user://TaskManager.exe"

func GetSettings():
	return [
		BackgroundCol, 
		UpdatePath
	]
