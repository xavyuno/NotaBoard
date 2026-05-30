extends Node

signal StartedDragging
signal StoppedDragging
signal ObjectAdded
signal ObjectRemoved
signal SaveObjectData
signal ChangeBoard
signal StoppedSelecting
signal Searched

var RemovedHistory: = []
var StoredHistory: = []
var StillLoading: = true

var MouseInCanvas: = true
var MousePos: Vector2
var CamPos: Vector2
var CamZoom: Vector2
var InFocus: = false
var DraggingObject: = false
var DraggedObject: PackedScene

var CurrentPage: = "Home"
var PageTitle: = "Home"
var PreviousPage: = "Home"
var PreviousTitle: = "Home"
var Boards: = []

var SelectedObject = null
var MultiSelectedObjects = []
var MultiSelecting = false
var AllSameSelectedObjects = false
var CopiedObject = null

var ProgressiveLoading: = true
var LoadDur: = 0.1
