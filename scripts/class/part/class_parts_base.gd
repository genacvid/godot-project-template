extends Resource
class_name Part

@export_group("Universal Stats")
@export var part_name:String = "Unknown"
@export var part_desc:String = "Unknown"
@export var part_class:String = "None"
@export var stat_display:Array = [
	"part_name",
	"part_desc",
	"part_class",
	"weight",
	"energy_cost",
	"price",
]
@export_range(5000,200000,1000) var price:int = 1000
@export var sellable:bool = true
@export var weight:int = 170
@export var energy_cost:int = 20
@export_group("Physical Attachment")
@export var model:String
