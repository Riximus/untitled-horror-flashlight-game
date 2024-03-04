extends Node3D

class_name ItemManager

@export var image_slots: Array[TextureRect]
@export var ui_slots: Array[Control]
@export var item_resources: Array[ItemResource]

var cur_items: Array[Item] = [null, null, null]
var cur_item_idx: int = 0
var cur_item: Item = null
var item_offset: Vector3 = Vector3.ZERO

@onready var slot_count: int = ui_slots.size()
@onready var pointer: ColorRect = $"../Head/Eyes/Camera3D/UIHolder/Pointer"
@onready var note_pos: Node3D = $"../Head/Eyes/Camera3D/NotePos"
@onready var pickup_pos: Node3D = $"../Head/Eyes/Camera3D/PickupPos"

func get_item_count():
	return cur_items.filter(func(itm): return itm != null).size()

func set_pointer_target():
	pointer.global_position.x = ui_slots[cur_item_idx].global_position.x
	
func update_slot_images():
	for i in range(image_slots.size()):
		if cur_items[i] != null:
			image_slots[i].texture = cur_items[i].item_resource.item_slot_image
			image_slots[i].visible = true
		else:
			image_slots[i].visible = false

func change_cur_item(new_item: Item):
	if cur_item:
		cur_item.visible = false
	cur_item = new_item
	item_offset = Vector3.ZERO
	
func pickup_item(item: Item):
	change_cur_item(item)
	cur_item_idx = 0
	set_pointer_target()
	cur_items.push_front(item)
	cur_items.pop_back()
	update_slot_images()
	
func drop_cur_item():
	cur_items.erase(cur_item)
	cur_items.push_back(null)
	cur_item = null
	if cur_items[cur_item_idx]:
		cur_items[cur_item_idx].visible = true
	change_cur_item(cur_items[cur_item_idx])
	update_slot_images()
	
func switch_cur_item(dir: int):
	cur_item_idx = (cur_item_idx + dir) % slot_count
	if cur_item_idx < 0: cur_item_idx = slot_count - 1
	print(cur_item_idx)
	change_cur_item(cur_items[cur_item_idx])
	if cur_item:
		cur_item.visible = true
	set_pointer_target()

func _input(event):
	if event.is_action_pressed("ui_up"):
		switch_cur_item(1)
	if event.is_action_pressed("ui_down"):
		switch_cur_item(-1)

func _ready():
	set_pointer_target()

func _enter_tree():
	item_resources[0].item_action = func():
		print("flash")
	
	item_resources[1].item_action = func():
		cur_item.get_node("Label3D").visible = not cur_item.get_node("Label3D").visible
		if item_offset == Vector3.ZERO:
			item_offset = note_pos.position - pickup_pos.position
		else:
			item_offset = Vector3.ZERO
