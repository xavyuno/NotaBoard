extends Node

signal ApplyCustomization(alter : String)
signal Reload
signal ApplyTheme

var SelectedTheme := "Default"
var DefaultTheme := "Default"
var DefaultFont := preload("uid://dted0h48sl1cj")

var OriginalData = []

var Themes := {
	"Default" : {
		"Style" : preload("uid://cys4q33k6i8ws"),
		"Font" : DefaultFont,
		"FontColor": Color.WHITE
		},
	"Application Default" :{
		"Style": preload("uid://cb45ybrjq3nvu"),
		"Font": DefaultFont,
		"FontColor": Color.WHITE
	},
	"Empty" : {
		"Style":  preload("uid://bf31usjuypohc"),
		"Font" : DefaultFont,
		"FontColor": Color.WHITE
	},
	"Outline": {
		"Style" : preload("uid://dgeoaby8qo30b"),
		"Font": DefaultFont,
		"FontColor": Color.WHITE
	},
	"LightMode" :{
		"Style": preload("res://App/Resources/LightMode.tres"),
		"Font": DefaultFont,
		"FontColor": Color.BLACK
	}

}

var Config := {
	"Notes" : "Default",
	"Board" : "Default",
	"Canvas" : "Outline",
	"File" : "Outline",
	"Link" : "Outline",
	"Column" : "Default",
	"Foldable" : "Default",
	"ToDo": "Default"
}

func Remove(Style):
	if Themes.has(Style):
		if DefaultTheme == Style:
			DefaultTheme = "Default"
		if SelectedTheme == Style:
			SelectedTheme = "Default"
		for i in Config.keys():
			if Config[i] == Style:
				Config[i] = "Default"
		Themes.erase(Style)
	emit_signal("Reload")
