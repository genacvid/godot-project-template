@icon("res://resources/gui/inventory.svg")
extends Component
class_name InventoryComponent
@onready var slots:Array[Node] = self.get_children()
@export var weapon_transform:RemoteTransform3D
var current_slot:int = 0
var slot_active:bool = false
func switch_slot(idx:int):
	if not slot_has_weapon(idx): return
	if current_slot == idx and slot_active:
		slot_active = !slot_active
		entity.attack.current_weapon = null
		#slot_get_weapon(idx).visible = false
		slot_set_visible.rpc(idx,false)
		return
	else:
		current_slot = idx
		slot_active = true
	if slot_has_weapon(idx):
		if entity.attack.current_weapon: hide_current_weapon.rpc()
		slot_set_visible.rpc(idx,slot_active)
		entity.attack.current_weapon = slots[idx].get_child(0)
		set_weapon_transform.rpc(slot_get_weapon(idx).get_path())
		entity.attack.current_weapon.reset_physics_interpolation()
func slot_has_weapon(idx:int) -> bool: return slots[idx].get_child_count() > 0
func slot_get_weapon(idx:int) -> Weapon: return slots[idx].get_child(0)
@rpc("any_peer","call_local")
func slot_set_visible(idx:int,toggle:bool) -> void: slot_get_weapon(idx).visible = toggle
@rpc("any_peer","call_local")
func hide_current_weapon(): entity.attack.current_weapon.hide()
@rpc("any_peer","call_local")
func set_weapon_transform(path): weapon_transform.remote_path = path
