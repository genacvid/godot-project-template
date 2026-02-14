extends Node

const DEBUG_VALUE_SNAP_FLOAT = 0.01
const DEBUG_VALUE_SNAP_VEC3 = Vector3.ONE * DEBUG_VALUE_SNAP_FLOAT
const DEBUG_VALUE_SNAP_VEC2 = Vector2.ONE * DEBUG_VALUE_SNAP_FLOAT
const DEBUG_PRINT_GAME = "	[b][color=green]GAME: [/color][/b]"
const DEBUG_PRINT_LOADING = "	[b][color=grey]LOADING: [/color][/b]"
const DEBUG_PRINT_DEBUG = "	[b][color=yellow]DEBUG: [/color][/b]"
const DEBUG_PRINT_SAVE = "	[b][color=red]SAVE: [/color][/b]"
const DEBUG_PRINT_SETTING = "	[b][color=pink]SETTING: [/color][/b]"
const DEBUG_PRINT_ADDON = "	[b][color=cyan]ADDON: [/color][/b]"
const DEBUG_PRINT_SESSION_HOST = "	[b][color=orange]SESSION HOST: [/color][/b]"
const DEBUG_PRINT_SESSION_CLIENT = "	[b][color=aquamarine]NETPLAY CLIENT: [/color][/b]"
const DEBUG_PRINT_ERROR = "	[b][color=red]ERROR! [/color][/b]"
const DEBUG_PRINT_WARNING = "	[b][color=yellow]WARNING! [/color][/b]"

func say(key:String,value):
	if value is Vector2: value = snapped(value,DEBUG_VALUE_SNAP_VEC2)
	if value is Vector3: value = snapped(value,DEBUG_VALUE_SNAP_VEC3)
	if value is float: value = snapped(value,DEBUG_VALUE_SNAP_FLOAT)
	DebugDraw2D.set_text(key,value,0,Color.WHITE,-1.0)

func line(from:Vector3,to:Vector3): DebugDraw3D.draw_line(from,to)

const DEFAULT_BOX_SIZE = Vector3(0.1,0.1,0.1)
func box(to:Vector3,duration:float = 0.0, size:Vector3 = DEFAULT_BOX_SIZE,color:Color=Color.RED):
	DebugDraw3D.draw_box(to,Quaternion.from_euler(Vector3.UP),size,color,true,duration)

const DEFAULT_SPHERE_SIZE = 0.1
func sphere(to:Vector3,duration:float = 0.0, size:float = DEFAULT_SPHERE_SIZE,color:Color=Color.RED):
	DebugDraw3D.draw_sphere(to,size,color,duration)
