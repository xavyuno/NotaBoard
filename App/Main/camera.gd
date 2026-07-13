extends Camera2D

@onready var drag: Area2D = $Drag

var Dragging = false
var DragSelecting := false
var DragSelectPos := Vector2.ZERO
var ZoomScale = Vector2(0.01, 0.01)

func _ready() -> void :
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))
	User.connect("ChangeBoard", Callable(self, "ChangeBoard"))

func SettingsChanged():
	$ClearFocus.color = Settings.BackgroundCol

func ResetCam():
	position = Vector2(640, 352)
	zoom = Vector2(1, 1)

func ChangeBoard(Board: String, Title: String, ID = "", CamPos = Vector2(640, 352)):
	if Board == "Settings":
		position = User.CamPosSettings
	else :
		if Board == "Home":
			position = User.CamPosBoard
		elif Board == "Calendar":
			position = User.CamPosCalendar
		else :
			position = CamPos

func _draw() -> void:
	if User.DragSelecting and !(User.CurrentPage in ["Settings", "Calendar"]):
		draw_polyline(
				System.CreateRectangle(DragSelectPos, get_local_mouse_position()),
			Settings.DragCol,
			2.5
		)

func _physics_process(delta: float) -> void :
	User.CamZoom = zoom
	User.CamPos = position
	if User.CurrentPage == "Settings":
		User.CamPosSettings = position
	else:
		if User.CurrentPage == "Home":
			User.CamPosBoard = position
		elif User.CurrentPage == "Calendar":
			User.CamPosCalendar = position
	if Input.is_action_just_pressed("ResetCam"):
		ResetCam()
	if Input.is_action_pressed("Drag"):
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
	
	if Input.is_action_pressed("Click") and User.DragSelecting:
		drag.get_node("CollisionPolygon2D").polygon = System.CreateRectangle(DragSelectPos, get_local_mouse_position())
	if Input.is_action_just_pressed("Click") and !User.MouseInCanvas:
		DragSelectPos = get_local_mouse_position()
		DragSelecting = true
		$Timer.start()
	if Input.is_action_just_released("Click"):
		User.DragSelecting = false
		DragSelecting = false
	drag.get_node("CollisionPolygon2D").disabled = !User.DragSelecting

func CamConditions():
	if !User.InFocus and (!User.MouseInCanvas or User.CanvasHidden):
		return true
	else :
		return false

func _process(delta: float) -> void :
	$ClearFocus.global_position = User.CamPos - Vector2(10000, 10000)
	queue_redraw()

func _input(event: InputEvent) -> void :
	if event is InputEventMouseButton and !Input.is_action_pressed("MultiSelect"):
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and zoom.x <= 10 and CamConditions():
			zoom += ZoomScale
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and zoom.x >= 0.1 and CamConditions():
			zoom -= ZoomScale
	if event is InputEventMouseMotion:
		if Dragging:
			position += - event.relative / User.CamZoom.clamp(Vector2(0, 0), Vector2(10, 10))


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
