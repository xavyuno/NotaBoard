extends Node

signal ApplyCustomization
signal Reload

var SelectedTheme := "Default"
var DefaultTheme := "Default"

var Themes := {
	"Default" : {
		"Style" : preload("uid://cys4q33k6i8ws"),
		"Font" : preload("uid://bnkyxirvuyr1j")
		},
	"Empty" : {
		"Style":  preload("uid://bf31usjuypohc"),
		"Font" : preload("uid://bnkyxirvuyr1j")
	}
}

var Config := {
	"Notes" : "Default",
	"Board" : "Default",
	"Canvas" : "Empty",
	"File" : "Empty",
	"Link" : "Empty",
	"Column" : "Default",
	"Foldable" : "Default"
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
