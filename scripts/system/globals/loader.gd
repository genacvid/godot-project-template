extends Node

var loading:bool = false
var load_progress:Array[float] = []
var load_queue:Array[String] = []
signal loaded(object:Resource)
@onready var loading_layer: CanvasLayer = $LoadingLayer
@onready var progress_bar: ProgressBar = $LoadingLayer/LoadingControl/ProgressBar

func queue(path:String,hint:String):
	var err = ResourceLoader.load_threaded_request(path,hint)
	if err != OK:
		OS.alert("Error code " + str(err) + " occured on resource request.","CRITICAL ERROR")
		get_tree().quit(err)
	load_queue.append(path)
	progress_bar.value = 0.0

func _process(_delta: float) -> void:
	loading = not load_queue.is_empty()
	if loading:
		var path:String = load_queue.front()
		var status:int = ResourceLoader.load_threaded_get_status(path,load_progress)
		progress_bar.value = load_progress[0] * 100.0
		match status:
			ResourceLoader.THREAD_LOAD_LOADED:
				loaded.emit(ResourceLoader.load_threaded_get(path))
				load_queue.pop_front()
				load_progress = []
			ResourceLoader.THREAD_LOAD_FAILED:
				OS.alert("Failed to load resource " + path, "CRITICAL ERROR")
				get_tree().quit(ResourceLoader.THREAD_LOAD_FAILED)
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				OS.alert("Could not find resource at " + path, "CRITICAL ERROR")
				get_tree().quit(ResourceLoader.THREAD_LOAD_INVALID_RESOURCE)
