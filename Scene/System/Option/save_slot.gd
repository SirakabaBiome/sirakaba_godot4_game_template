extends HBoxContainer

@onready var thumb_img = $Thumbnail/Thumb_IMG
@onready var slot_name = $Info/Slot_Name
@onready var player_name = $Info/Player_Name
@onready var map_name = $Info/Map_Name
@onready var total_play_time = $Info/Total_PlayTime
@onready var save_date = $Info/Save_Date
var slot_origin_name

signal save
signal load

func _ready():
	slot_origin_name = slot_name.text

func slot_set(data,id):
	if slot_origin_name == slot_name.text:
		slot_name.text = slot_name.text + str(id)
	if not data["player_name"] == "NULL":
		if not data["save_img"] == false:
			thumb_img = data["save_img"]
		player_name.text = data["player_name"]
		map_name.text = data["map_name"]
		total_play_time.text = data["total_play_time"]
		save_date.text = Time.get_datetime_string_from_datetime_dict(data["save_date"],true)

func _on_save_pressed():
	emit_signal("save")

func _on_load_pressed():
	emit_signal("load")
