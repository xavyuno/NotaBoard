extends Camera2D

var Dragging = false
var ZoomScale = Vector2(0.01, 0.01)

func _ready() -> void :
    Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))

func SettingsChanged():
    $ClearFocus.color = Settings.BackgroundCol

func _physics_process(delta: float) -> void :
    User.CamZoom = zoom
    User.CamPos = position
    if Input.is_action_just_pressed("ResetCam"):
        position = Vector2(640, 360)
    if Input.is_action_pressed("Drag"):
        Dragging = true
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    if Input.is_action_just_released("Drag"):
        Dragging = false
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    User.MousePos = get_local_mouse_position() + position

    if Input.is_action_pressed("ZoomIn") and zoom.x <= 10 and !User.InFocus:
        zoom += ZoomScale
    if Input.is_action_pressed("ZoomOut") and zoom.x >= 0.1 and !User.InFocus:
        zoom -= ZoomScale

func _process(delta: float) -> void :
    $ClearFocus.global_position = User.CamPos - Vector2(10000, 10000)

func _input(event: InputEvent) -> void :
    if event is InputEventMouseMotion:
        if Dragging:
            position += - event.relative / User.CamZoom.clamp(Vector2(0, 0), Vector2(10, 10))
