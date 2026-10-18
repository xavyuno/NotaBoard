extends Camera2D

@onready var drag: Area2D = $Drag


var Dragging = false
var DragSelecting := false
var DragSelectPos := Vector2.ZERO
var ZoomScale = Vector2(0.01, 0.01)

#Smooth zoom and positon to designated place
var ToPos : Vector2
var ToZoom : Vector2
var Travelled := true

#Drawing
var StartPos = Vector2.ZERO
var TempObj = null

func _ready() -> void :
	$ClearFocus.visible = true
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))
	User.connect("ChangeBoard", Callable(self, "ChangeBoard"))

func SettingsChanged():
	$ClearFocus.self_modulate = Settings.Data["BackgroundCol"]

func ResetCam():
	position = Vector2(640, 352)
	zoom = Vector2(1, 1)

func ChangeBoard(_Board: String, _Title: String, _ID = "", CamPos = Vector2(640, 352), CamZoom = Vector2(1, 1)):
	User.PreviousPos = position
	ToPos = CamPos
	ToZoom = CamZoom if typeof(CamZoom) == TYPE_VECTOR2 else Vector2(1,1)
	Travelled = false

func _draw() -> void:
	if User.DragSelecting and !get_node("../Boards/" + Settings.Data["CurrentPage"]).is_in_group("NoCanvas"):
		draw_polyline(
				System.CreateRectangle(DragSelectPos, get_local_mouse_position()),
			Settings.Data["DragCol"],
			2 / User.CamZoom.x
		)

func _physics_process(_delta: float) -> void :
	$ClearFocus.scale = Vector2(1, 1) / User.CamZoom * 10
	if !Travelled:
		if (position.distance_to(ToPos) > 1) or (zoom.distance_to(ToZoom) > 1):
			position = lerp(position, ToPos, 0.21)
			zoom = lerp(zoom, ToZoom, 0.21)
		else:
			Travelled = true
	
	User.CamZoom = zoom
	User.CamPos = position
	if Settings.Data["CurrentPage"] in ["Settings", "Home", "Calendar"]:
		Settings.Data["CamPos" + Settings.Data["CurrentPage"]] = position
		Settings.Data["CamZoom" + Settings.Data["CurrentPage"]] = zoom

	if Input.is_action_just_pressed("Special") and CamConditions():
		Settings.Data["GridSnap"] = true
	if Input.is_action_just_released("Special"):
		Settings.Data["GridSnap"] = false
	if Input.is_action_just_pressed("ResetCam"):
		ResetCam()
	if Input.is_action_pressed("Drag") and CamConditions():
		Travelled = true
		Dragging = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if Input.is_action_just_released("Drag"):
		Dragging = false
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	User.MousePos = get_local_mouse_position() + position

	if Input.is_action_pressed("ZoomIn") and zoom.x <= 10 and CamConditions():
		zoom += ZoomScale
	if Input.is_action_pressed("ZoomOut") and zoom.x >= 0.1 and CamConditions():
		zoom -= ZoomScale
	
	if Input.is_action_pressed("Click") and User.DragSelecting and !get_node("../Boards/" + Settings.Data["CurrentPage"]).is_in_group("NoCanvas"):
		drag.get_node("CollisionPolygon2D").polygon = System.CreateRectangle(DragSelectPos, get_local_mouse_position())
	if Input.is_action_just_pressed("Click") and !User.MouseInCanvas and !User.InFocus:
		DragSelectPos = get_local_mouse_position()
		DragSelecting = true
		$DragTimer.start()
	if Input.is_action_just_released("Click"):
		User.DragSelecting = false
		DragSelecting = false
	drag.get_node("CollisionPolygon2D").disabled = !User.DragSelecting

func CamConditions():
	if (!User.InFocus and !Input.is_action_pressed("MultiSelect")) and (!User.MouseInCanvas or User.CanvasHidden or User.History.size() <= 9) and !User.DrawingInCanvas:
		return true
	else :
		return false

func _process(_delta: float) -> void :
	$ClearFocus.position = Vector2(-640, -352) / User.CamZoom * 10
	queue_redraw()

func _input(event: InputEvent) -> void :
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and zoom.x < 10 and CamConditions():
			zoom += ZoomScale
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and zoom.x > 0.1 and CamConditions():
			zoom -= ZoomScale
	if event is InputEventMouseMotion:
		if Dragging:
			position += - event.relative / User.CamZoom


func _on_drag_body_entered(body: Node2D) -> void:
	if User.DragSelecting:
		body.get_parent().call_deferred("FocusItem")

func _on_drag_body_exited(body: Node2D) -> void:
	if User.DragSelecting:
		body.get_parent().call_deferred("ext", true)


func _on_timer_timeout() -> void:
	if DragSelecting:
		User.DragSelecting = true
	else :
		User.DragSelecting = false
	DragSelecting = false
