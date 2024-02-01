extends Node3D

var mouse_movement
var sway_threshold: float = 5.0
var sway_lerp: float = 5.0

@export var sway_left: Vector3
@export var sway_right: Vector3
@export var sway_normal: Vector3

func _ready():
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_movement = -event.relative.x
		
func _process(delta: float) -> void:
	if mouse_movement != null:
		if mouse_movement > sway_threshold:
			rotation = rotation.lerp(sway_left, sway_lerp * delta)
		elif mouse_movement < -sway_threshold:
			rotation = rotation.lerp(sway_right, sway_lerp * delta)
		else:
			rotation = rotation.lerp(sway_normal, sway_lerp * delta)
