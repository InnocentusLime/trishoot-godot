extends Node2D

@onready var window: Window = get_window() 
@onready var base_width: int = ProjectSettings.get_setting("display/window/size/viewport_width")
@onready var base_height: int = ProjectSettings.get_setting("display/window/size/viewport_height")

func _ready() -> void:
	window.size_changed.connect(_on_window_size_changed) 
	var min_x = ProjectSettings.get_setting("display/window/size/viewport_width")
	var min_y = ProjectSettings.get_setting("display/window/size/viewport_height")
	window.min_size = Vector2i(min_x, min_y)

func _on_window_size_changed():
	var base_size = Vector2i(base_width, base_height)
	print("window.size: ", window.size) 
	
	var scale = (window.size.y + base_height - 1) / base_height
	print("scale: ", scale) 
	
	print("content_scale_size: ", window.content_scale_size)
	window.content_scale_size = window.size / Vector2i(scale, scale)
	
