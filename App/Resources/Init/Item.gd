extends Control
class_name Item

var Data: = {
	"Type": "Board", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"ID": "Home", 
}

func SyncDefault():
	Data["Pos"] = position
	Data["Size"] = size

func AddData(extraData : Array):
	for i in extraData:
		Data.merge(i, true)

func GetData() -> Dictionary:
	return Data

func UpdateValues(NODE, value, parameter):
	if Data.has(value):
		NODE.call_deferred("set", parameter, Data[value])
