@icon("res://resources/gui/weapon.svg")
extends Node3D
class_name Weapon

@export var attack_data:AttackData
@export var viewmodel_root:Node3D
@export var melee_hitbox:Area3D
@export var muzzle:Marker3D

func toggle_viewmodel(toggle:bool): viewmodel_root.visible = toggle
func _ready() -> void: self.hide()
