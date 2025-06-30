extends Area2D

@export_enum("NORMAL", "DEBUG") var mode: String = "NORMAL"

@export var long_click_duration: float = 1.0
@export var min_drag_dist: int = 20

@onready var hitbox = $CollisionShape2D # Reference to the collision shape

var is_clicking: bool = false
var is_long: bool = false
var is_drag: bool = false

var click_start_time: float = 0.0
var click_event: InputEvent

signal mouse_down(event:InputEventMouseButton)
signal mouse_up(event:InputEventMouseButton)
signal mouse_press(event:InputEventMouseButton)

signal double_click(event:InputEventMouseButton)
signal long_click(event:InputEventMouseButton)
signal drag(event:InputEventMouseMotion)


func _process(_delta):
	if is_clicking and not is_long and not is_drag:
		var click_duration = (Time.get_ticks_msec()/1000.0) - click_start_time
		if click_duration >= long_click_duration:
			if mode == "DEBUG":
				print("Long Click on " + name)
			emit_signal("long_click", click_event)
			
			is_long = true

func _input(event):
		if event is InputEventMouseButton:
			if not event.pressed and is_clicking:
				
				if is_clicking:
					if mode == "DEBUG":
						print("Click Press on: " + name)
					emit_signal("mouse_press", event)
				
				
				if mode == "DEBUG":
					print("Click Release on: " + name)
				emit_signal("mouse_up", event)
				
				
				is_clicking = false
				is_long = false
				is_drag = false

func _unhandled_input(event):
		if event is InputEventMouseButton:
			if event.pressed and hit_check(to_local(event.global_position)):
				
				if mode == "DEBUG":
					print("Click Down on: " + name)
				emit_signal("mouse_down", event)
				
				if event.is_double_click():
					if mode == "DEBUG":
						print("Double Click on: " + name)
					emit_signal("double_click", event)
				
				is_clicking = true
				click_event = event
				click_start_time = Time.get_ticks_msec() / 1000.0
		
		
		if event is InputEventMouseMotion:
			if is_clicking:
				if not is_drag and click_event.global_position.distance_to(event.global_position) >= min_drag_dist:
					
					if mode == "DEBUG":
						print("Click Drag on: " + name)
					var drag_event = event.duplicate()
					drag_event.global_position = click_event.global_position
					drag_event.relative = click_event.global_position - event.global_position
					emit_signal("drag", drag_event)
					
					is_drag = true

func hit_check(mouse_position: Vector2):
	if hitbox.shape is RectangleShape2D:
		var checkX = mouse_position.x >= hitbox.position.x - hitbox.shape.size.x/2 and mouse_position.x <= hitbox.position.x + hitbox.shape.size.x/2
		var checkY = mouse_position.y >= hitbox.position.y - hitbox.shape.size.y/2 and mouse_position.y <= hitbox.position.y + hitbox.shape.size.y/2
		return checkX and checkY
	elif hitbox.shape is CircleShape2D:
		var dist = sqrt(pow(mouse_position.x-hitbox.global_position.x,2) + pow(mouse_position.y-hitbox.global_position.y,2))
		return dist <= hitbox.shape.radius
	push_warning(name, " hitbox is not of type RectangleShape2D or CircleShape2D")
	return false
