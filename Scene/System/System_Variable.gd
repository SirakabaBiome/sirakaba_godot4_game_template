extends Node

var in_game = false
var in_event = false
var in_battle = false
var in_option_enabled = true

var system_value = {
	"Sound":{
		"Master": -6,
		"BGM": -1,
		"BGS": -1,
		"ME": -1,
		"SE": -1,
		"VOICE": -1
	},
	"Visual":{
		"Flash": true
	}
}

var time_data = {
	"start_time": 0, #ゲームスタート時の時間
	"save_time": 0, #ゲームをセーブした時間
	"now_playtime": 0, #今回遊んでいる時間
}
# ゲームをセーブした時間（または現在の時間） - ゲームスタート時の時間 = 今回遊んでいる時間
# ゲームをセーブするたびに今回遊んでいる時間とゲームをプレイした累計時間に足してゲームをセーブした時間とゲームスタート時の時間を初期化

var item_data = {
	
}

var player_data = {
	"player_name" : "",
	"map_name" : "",
	"start_date": {},
	"total_play_time": "",
	"total_play_time_unix": 0,
	"save_img": false,
	"save_date": {},
	"item_data": {},
}

# Called when the node enters the scene tree for the first time.
func _ready():
	game_start()

func game_start():
	time_data["start_time"] = get_now_time("unix")
	player_data["start_date"] = get_now_time("dict")

func game_continue():
	time_data["start_time"] = get_now_time("unix")

func playtime_calculation():
	var start_time = time_data["start_time"]
	var now_time = get_now_time("unix")
	var play_time = now_time - start_time
	player_data["total_play_time_unix"] = player_data["total_play_time_unix"] + play_time
	var play_date = Time.get_datetime_dict_from_unix_time(player_data["total_play_time_unix"])
	var play_hour = (play_date["day"] - 1) * 24 + play_date["hour"] 
	player_data["total_play_time"] = str(play_hour) + ":" + str(play_date["minute"]) + ":" + str(play_date["second"])
	time_data["start_time"] = get_now_time("unix")

func get_now_time(type):
	var now_time = Time.get_datetime_dict_from_system()
	match type:
		"unix":
			return Time.get_unix_time_from_datetime_dict(now_time)
		"dict":
			return now_time

func system_value_save():
	var config_file = FileAccess.open("user://config.save", FileAccess.WRITE)
	var json_string = JSON.stringify(system_value)
	config_file.store_line(json_string)

func system_value_load():
	if not FileAccess.file_exists("user://config.save"):
		return
	
	var config_file = FileAccess.open("user://config.save", FileAccess.READ)
	system_value = JSON.parse_string(config_file.get_line())

func game_data_save(slot):
	var save_file = FileAccess.open("user://savefile_" + str(slot) + ".save", FileAccess.WRITE)
	player_data["item_data"] = item_data
	player_data["save_date"] = get_now_time("dict")
	playtime_calculation()
	var json_string = JSON.stringify(player_data)
	save_file.store_line(json_string)

func game_data_load(slot):
	if not FileAccess.file_exists("user://savefile_" + str(slot) + ".save"):
#		print("FileNotFound")
		return {"player_name":"NULL"}
	
	var save_file = FileAccess.open("user://savefile_" + str(slot) + ".save", FileAccess.READ)
	time_data["start_time"] = get_now_time("unix")
	return JSON.parse_string(save_file.get_line())
