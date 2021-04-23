extends Camera2D

export var minZoom:float = 0.5
export var maxZoom:float = 2
export var noHorizontal:bool = false
export var noVertical:bool = false

var dragOrigin:Vector2
var dragging:bool = false

func _ready() -> void:
	position = get_viewport_rect().size / 2

func _process(delta:float):
	pass

func _unhandled_input(event:InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			if event.pressed:
				dragOrigin = event.position
				dragging = true
			else:
				dragging = false
		elif event.button_index == BUTTON_WHEEL_UP:
			zoom = Vector2.ONE * clamp(zoom.x * 0.95, minZoom, maxZoom)
		elif event.button_index == BUTTON_WHEEL_DOWN:
			zoom = Vector2.ONE * clamp(zoom.x * 1.05, minZoom, maxZoom)
	elif event is InputEventMouseMotion:
		if dragging:
			if noHorizontal:
				event.relative.x = 0
			if noVertical:
				event.relative.y = 0
			position -= event.relative * zoom.x
