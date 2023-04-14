extends Node

@export var bgm_node_list : Dictionary
@export var loop_se_node_root : NodePath
@export var loop_VOICE_node_root : NodePath
@export var bgs_node_list : Array
@export var voice_node : Array
var bgm_type = ""
var in_debug : bool = false

# node_list_setup : bgm_node_listのノードを全部get_nodeする
# bgm_play_debug : テスト用
# bgm_resource_debug : デバッグ用。リソースリストをコンソールに吐き出す
# bgm_play : BGMを再生する
# bgm_list_assign : bgm_playで使う
# bgm_fade : フェード再生機能
# bgm_stop : BGMを止める
# bgm_all_stop : とにかく全部止める
# bgm_resume_play : 直前まで再生していたものをまた再生する
# bgm_change : 再生位置を維持して即時に切り替える
# 例
# Sound.bgm_play("リソースパス","タイプ") BGM再生
# Sound.bgm_all_stop() : BGM全部止め
# Sound.resume_play() : BGM再開
# Sound.bgm_change() : 再生位置を維持して即時に切り替える[

func _ready():
	node_list_setup()

func node_list_setup():
	var node_value_list = bgm_node_list.values()
	var node_key_list = bgm_node_list.keys()
	for i in bgm_node_list.size():
		var array = []
		var list = node_value_list[i]
		var key = node_key_list[i]
		for n in list.size():
			array.append(get_node(list[n]))
		bgm_list_assign(array,key)

func bgm_play_debug():
	pass

func bgm_resource_debug():
	#　デバッグ用 in_debugをfalseにすると実行されない
	if in_debug == false:
		return
	var list_name = bgm_node_list.keys()
	print("BGMタイプ：" + bgm_type)
	for i in bgm_node_list.size():
		var array = bgm_node_list.values()
		var list = array[i]
		print(list_name[i])
		for n in list.size():
			var node = list[n]
			var path
			if node.stream:
				path = str(node.stream.resource_path)
			else:
				path = "NULL"
			print(node.name + ":" + path)
		print(list)

func bgm_play(path,type):
	# マップBGMとイベントBGMはここで再生する
	var list = bgm_node_list[type]
	var is_true = false # レジューム処理が入るか入らないか
	var now_bgm_list
	var bgm_node_list_values = bgm_node_list.values()
	if not bgm_type == "":
		now_bgm_list = bgm_node_list[bgm_type]
		if not type == bgm_type:
			bgm_stop(bgm_node_list[bgm_type])
	for i in bgm_node_list.size(): # 直近で再生したか見る
		var node_list = bgm_node_list_values[i]
		var finish = false
		for n in node_list.size():
			var node = node_list[n] # リストからノードを取得する
			if node.stream: # ノードにリソースが入っているか
				if node.stream.resource_path == path: # ノードのリソースと今回再生したいリソースが同じか
					is_true = true # 同じなので新規再生の処理を挟まなくする
					if node.stream_paused: # ノードがポーズ中か
						var node_2 = now_bgm_list[-1] # リストで一番最近再生したノードを取得する
						if node_2 == node: # 同じだったらこれ以降の処理は不要
							return
						if node_2.playing: 
							bgm_fade(node_2, "out") # 再生されていたら止める
						bgm_fade(node,"in") 
						node.stream_paused = false # 再生する
						list.erase(node) # リストから削除して
						list.append(node) # 一番最近再生したことにする
						finish = true
						break
					else: # ポーズ中なら無視する
						finish = true
						break
		if finish:
			break
	if is_true: # 同じなので新規再生の処理を挟まなくする
		bgm_list_assign(list,type) # リストを大元のやつに入れ直す
		bgm_resource_debug() # 削除しても良い
		return # 同じなので新規再生の処理を挟まなくする
	for i in list.size(): # 再生しているやつを止める
		var node = list[i]
		if node.playing:
			bgm_fade(node,"out")
			break
	var next_node = list[0] # 一番古いノードを取得する
	next_node.stream = load(path) # ノードにリソースを読み込ませる
	next_node.play(0) # 再生させる 
	bgm_fade(next_node,"in") # フェードインさせる
	list.erase(next_node) # リストから削除して
	list.append(next_node) # 一番最近再生したことにする
	bgm_list_assign(list,type) # リストを大元のやつに入れ直す
	bgm_type = type
	bgm_resource_debug() # 削除しても良い

func bgm_list_assign(list,type): # 渡されたリストをタイプごとに入れ直す
	bgm_node_list[type] = list

func bgm_fade(node,type):
	match type:
		"in":
			if node.volume_db > -50:
				return
#			await get_tree().create_tween().tween_property(node, "volume_db", -1, 3).finished # ３秒かけて音を大きくする
			get_tree().create_tween().tween_property(node, "volume_db", -1, 3)
			await get_tree().create_timer(3).timeout
		"out":
			if node.volume_db < -1:
				return
			await get_tree().create_tween().tween_property(node, "volume_db", -50, 3).finished # ３秒かけて音を小さくする
			node.stream_paused = true # ポーズモードにする

func bgm_stop(list:Array):
	var node = list[-1]
	if node.playing: # 再生してたら止める
		bgm_fade(node,"out")

func bgm_all_stop():
	for i in bgm_node_list.size():
		var list = bgm_node_list.values()
		bgm_stop(list[i])

func bgm_resume_play():
	# 一番最近のを再生する
	var list = bgm_node_list[bgm_type]
	var node = list[-1]
	node.stream_paused = false
	bgm_fade(node,"in")

func bgm_change(path):
	var list = bgm_node_list[bgm_type]
	var node = list[-1]
	var seek = node.get_playback_position()
	node.stream = load(path)
	node.play(seek)

# loop_set : 一定周期でSEやVOICEを再生する
#  L type : SEかVOICEか, id : ループするノードのID, time : ループ頻度, path_list : ランダムで再生する素材のリスト
# random_array : Arrayの中から１つを返す
# _timeout : タイマー切れの後SEを再生する
# loop_end : loopseやvoiceを止める

func loop_set(type,id,time,path_list):
	var node_path
	match type:
		"SE":
			node_path = str(loop_se_node_root) + "/Loop_SE_" + id
		"VOICE":
			node_path = str(loop_VOICE_node_root) + "/Loop_VOICE_" + id
	var timer : Timer = get_node(node_path + "/Timer")
	var sound_node : AudioStreamPlayer = get_node(node_path)
	if timer.is_stopped() == false:
		loop_end(type,id)
	time = int(time)
	path_list = JSON.parse_string(path_list)
	sound_node.stream = load(random_array(path_list))
	timer.timeout.connect(_timeout.bind(sound_node,time,path_list,node_path,timer))
	sound_node.play(0)
	timer.start(time)

func random_array(list:Array):
	randomize()
	return list[randi() % list.size()]

func _timeout(node,time,path_list,node_path,timer):
	node.stream = load(random_array(path_list))
	node.pitch_scale = randf_range(0.9,1.1)
	node.play(0)
	var random_zougen = randf_range(-1,1)
	timer.start(time + random_zougen)

func loop_end(type,id):
	var node_path
	match type:
		"SE":
			node_path = str(loop_se_node_root) + "/Loop_SE_" + id
		"VOICE":
			node_path = str(loop_VOICE_node_root) + "/Loop_VOICE_" + id
	var timer : Timer = get_node(node_path + "/Timer")
	timer.stop()

# bgs_play : 普通に素材のパス入れるだけで良い

func bgs_play(path):
	var node = get_node(bgs_node_list[0])
	node.stream = load(path)
	node.play(0)
	bgs_node_list.erase(node)
	bgs_node_list.append(node)

# se_play : 普通に素材のパス入れるだけで良い

func se_play(path):
	var node = get_node(str(loop_se_node_root) + "/SE")
	node.stream = load(path)
	node.play(0)
	
