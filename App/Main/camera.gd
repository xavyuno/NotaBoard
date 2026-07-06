extends Camera2D

var Dragging = false
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

func CamConditions():
	if !User.InFocus and (!User.MouseInCanvas or User.CanvasHidden):
		return true
	else :
		return false

func _process(delta: float) -> void :
	$ClearFocus.global_position = User.CamPos - Vector2(10000, 10000)

func _input(event: InputEvent) -> void :
	if event is InputEventMouseButton and !Input.is_action_pressed("MultiSelect"):
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and zoom.x <= 10 and CamConditions():
			zoom += ZoomScale
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and zoom.x >= 0.1 and CamConditions():
			zoom -= ZoomScale
	if event is InputEventMouseMotion:
		if Dragging:
			position += - event.relative / User.CamZoom.clamp(Vector2(0, 0), Vector2(10, 10))
