extends Node
var current_save_file:SaveFile
var current_save_name:String = "default"

func write_save_file():
	var directory = DirAccess.open("user://")
	if not directory.dir_exists("saves"):
		directory.make_dir("saves")
	ResourceSaver.save(current_save_file,"user://saves/" + current_save_name + ".tres")

func restore_save_file(save_name:String):
	var directory = DirAccess.open("user://")
	if not directory.file_exists(save_name + ".tres") or\
	not directory.dir_exists("saves"):
		write_save_file()
	current_save_file = ResourceLoader.load("user://saves/" + save_name + ".tres")
