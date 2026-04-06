extends Part
class_name PartFrame
@export_group("Frame Stats")
@export var vitality:int = 1000 ## Increases total vitality
@export var aerodynamics:int = 100 ## Increases aerial agility, decreasing air friction and increasing top acceleration
@export var defense_bullet: int = 0 ## Increases damage resistance to bullets
@export var defense_explosive: int = 0 ## Increases damage resistance to explosives
@export var defense_energy: int = 0 ## Increases damage resistance to energy attacks
@export var defense_nerve: int = 0 ## Increases nerve damage threshold
