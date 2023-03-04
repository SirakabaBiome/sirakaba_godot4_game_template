extends TabBar

@onready var master = %Master
@onready var bgm = %BGM
@onready var bgs = %BGS
@onready var me = %ME
@onready var se = %SE
@onready var voice = %VOICE
var sound_node_list

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func setup():
	sound_node_list = [master,bgm,bgs,me,se,voice]
	volume_set()

func volume_set():
	var audio_config = SVar.system_value["Sound"]
	for i in sound_node_list.size():
		var node = sound_node_list[i]
		var value = audio_config[node.name]
		node.value = value
		audio_bus_set(node.name,0)

func audio_bus_set(type,volume):
	var bus_index = AudioServer.get_bus_index(type)
	AudioServer.set_bus_volume_db(bus_index,volume)

func _on_volume_drag_ended(value_changed, node_name):
	var node = get_node("%" + node_name)
	SVar.system_value.Sound[node_name] = node.value
	SVar.system_value_save()

func _on_value_changed(value, node_name):
	audio_bus_set(node_name, value)
