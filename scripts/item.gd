extends RigidBody3D

class_name Item

enum ITEM{
	FLASHLIGHT,
}

@export var item: ITEM

@export var item_actions: Dictionary = {
	ITEM.FLASHLIGHT: func(): print("this is chaos")
}
