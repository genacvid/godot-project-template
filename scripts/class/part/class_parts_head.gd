extends PartFrame
class_name PartHead

@export_group("Head Functionality")
@export_range(80,175) var camera:int = 100 ## Affects range for scoped weapons.
@export_range(100,200) var recovery:int = 100 ## How quickly you recover from stability break
@export_range(100,300) var stability_modifier:int = 250 ## Multiplier for overall stability
@export_enum("Basic","Advanced","Special") var intelligence:int = 0 ## Type of computer for recon.

@export_group("Radar Functionality")
@export var has_radar:bool = false
@export_range(100,400) var radar_range_modifier:int = 100
@export_range(70,150) var radar_processing:int = 100
