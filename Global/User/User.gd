extends Node

signal StartedDragging
signal StoppedDragging
signal ObjectAdded
signal ObjectRemoved
signal SaveObjectData
signal ChangeBoard
signal StoppedSelecting
signal Searched
signal PreviewNotes
signal ItemFocused
signal ItemFocusLost
signal ChangedOptionsBar
signal AllFocusLost
signal SearchResultSend
signal SearchByQuery
signal ApplySearch
signal DeleteAllItemsByBoard
signal ApplySaveFile
signal MovedTodo
signal MovedTodoSuccess
signal DeleteItem
signal UpdateItem
signal ItemChanged
signal ApplyItemChange
signal ForceUpdateID
signal CreateNotif
signal DeleteAll

var SearchQueries := ["Note:", "Title:", "ID:", "Board:", "Type:", "Dir:", "ItemID:", "Tags:"]
var SearchResults := []
var SearchSen := 0.5

var OptionsEnabled := true

var History: = []
var StoredHistory: = []
var StillLoading: = true

var MouseInCanvas: = false
var CanvasHidden = false
var MouseInOpen := true
var DrawingInCanvas := false

var MousePos: Vector2
var CamPos: Vector2
var CamZoom : Vector2
var InFocus: = false
var DragSelecting := false
var DraggingObject: = false
var DraggedObject: PackedScene

var PreviousPage: = "Home"
var PreviousTitle: = "Home"
var PreviousPos := Vector2.ZERO
var Boards: = {}

var SelectedObject = null
var MultiSelectedObjects = []
var MultiCopiedObjects := []
var MultiSelecting = false
var AllSameSelectedObjects = false
var CopiedObject = null

var LoadDur: = 0.05

var TestingMode := false

var SelectedDate := [0, 0, 0]
var SavedEvents := {}
var CopiedData = {
	"Data" : null,
	"Size" : Vector2.ZERO
}
