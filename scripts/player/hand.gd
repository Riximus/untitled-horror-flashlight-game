extends Node3D

var mouse_movement_x
var sway_threshold: float = 5.0
var sway_lerp: float = 5.0

@export var sway_left: Vector3
@export var sway_right: Vector3
@export var sway_normal: Vector3

func _ready():
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_motion := event as InputEventMouseMotion
		mouse_movement_x = -mouse_motion.relative.x
		
func _process(delta: float) -> void:
	print(self.rotation)
	if mouse_movement_x != null:
		if mouse_movement_x > sway_threshold:
			rotation = rotation.lerp(sway_left, sway_lerp * delta)
		elif mouse_movement_x < -sway_threshold:
			rotation = rotation.lerp(sway_right, sway_lerp * delta)
		else:
			rotation = rotation.lerp(sway_normal, sway_lerp * delta)
