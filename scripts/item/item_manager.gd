extends Node3D

class_name ItemManager

@export var image_slots: Array[TextureRect]
@export var ui_slots: Array[Control]
@export var item_resources: Array[ItemResource]

var cur_items: Array[Item]
var item_count: int = 0
var cur_item_idx: int = 0
var cur_item: Item = null

@onready var slot_count: int = image_slots.size()

func update_slot_image(image: Texture):
	image_slots[cur_items.size()-1].texture = image
	image_slots[cur_items.size()-1].visible = true

func erase_slot_image():
	image_slots[cur_items.size()-1].visible = false

func change_cur_item(new_item: Item):
	if cur_item:
		cur_item.visible = false
	cur_item = new_item
	
func pickup_item(item: Item):
	change_cur_item(item)
	cur_items.push_front(item)
	image_slots[0]
	item_count += 1
	update_slot_image(item.item_resource.item_slot_image)
	
func drop_cur_item():
	cur_items.erase(cur_item)
	cur_item = null
	item_count -= 1
	erase_slot_image()
	
func switch_cur_item():
	cur_item_idx = (cur_item_idx + 1) % slot_count
	change_cur_item(cur_items[cur_item_idx] if cur_item_idx < cur_items.size() else null)
	if cur_item:
		cur_item.visible = true

func _input(event):
	if event.is_action_pressed("ui_up"):
		switch_cur_item()

func _enter_tree():
	item_resources[0].item_action = func():
		$"../Head/Hand/lightflash/SpotLight3D".visible = not $"../Head/Hand/lightflash/SpotLight3D".visible
