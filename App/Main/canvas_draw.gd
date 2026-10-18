extends HBoxContainer

func _process(_delta: float) -> void:
	visible = User.DrawingInCanvas or Canvas.InCanvas

func _on_color_picker_button_color_changed(color: Color) -> void:
	Canvas.Col = color

func _on_pixel_size_value_changed(value: float) -> void:
	Canvas.PixelSize = value
