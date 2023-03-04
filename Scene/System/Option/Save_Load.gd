extends TabBar

var slot_node_resource = preload("res://Scene/System/Option/save_slot_.tscn")
@onready var save_slot_list = $ScrollContainer/Save_Slot_List

func _ready():
	slot_create()

func _process(delta):
	pass

func slot_create():
	for i in 20:
		var id = i + 1
		var data = SVar.game_data_load(id)
		var slot_node = slot_node_resource.instantiate()
		slot_node.name = slot_node.name + str(id)
		save_slot_list.add_child(slot_node)
		slot_node.slot_set(data,id)
		slot_node.save.connect(save.bind(id))
		slot_node.load.connect(savedata_load.bind(id))

func save(id):
	SVar.game_data_save(int(id))
	var node = get_node("ScrollContainer/Save_Slot_List/Save_Slot_" + str(id))
	var data = SVar.game_data_load(id)
	node.slot_set(data,id)

func savedata_load(id):
	var data = SVar.game_data_load(int(id))
	if not data["player_name"] == "NULL":
		SVar.player_data = data
