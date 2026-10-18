extends Node

func _ready() -> void:
	Settings.connect("SettingsChanged", SettingsChanged)

func SettingsChanged():
	pass
