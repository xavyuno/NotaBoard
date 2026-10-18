extends Control

var ForSearchBar := false

func _ready() -> void:
	if ForSearchBar:
		for i in Settings.Data["FrequentlySearched"]:
			var butt = preload("res://App/Components/SuggestionPrompt/holder.tscn").instantiate()
			butt.get_node("Text").text = i
			butt.get_node("Close").connect("pressed", RemoveSuggestion.bind(i))
			butt.get_node("Text").connect("pressed", ApplySearch.bind(i))
			butt.name = i
			$Scroll/Holder.add_child(butt)
	else:
		pass #code for auto complete commands

func ApplySearch(ID):
	User.emit_signal("ApplySearch", ID)

func RemoveSuggestion(ID):
	Settings.Data["FrequentlySearched"].erase(ID)
	get_node("Scroll/Holder/" + ID).queue_free()
