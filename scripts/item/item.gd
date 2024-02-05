extends RigidBody3D

class_name Item

@export var item_resource: ItemResource
@export var model: Mesh

func _ready():
	if model:
		$MeshInstance3D.mesh = model
