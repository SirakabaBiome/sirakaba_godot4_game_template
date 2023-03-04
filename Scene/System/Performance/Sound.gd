extends Node

var map_bgm_node_list = []
var event_bgm_node_list = []
var battle_bgm_node_list = []
var bgm_node_list = {}
var bgm_type = ""
var in_debug = false

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
	map_bgm_node_list = [$Map_BGM/BGM_1,$Map_BGM/BGM_2,$Map_BGM/BGM_3] # ノードリスト作成
	event_bgm_node_list = [$Event_BGM/BGM_1,$Event_BGM/BGM_2,$Event_BGM/BGM_3] # ノードリスト作成
	battle_bgm_node_list = [$Battle_BGM/BGM_1]
	bgm_node_list = {
			"map" : map_bgm_node_list,
			"event" : event_bgm_node_list,
			"battle" : battle_bgm_node_list
		}

func bgm_play_debug():
	pass

func bgm_resource_debug():
	#　デバッグ用 in_debugをfalseにすると実行されない
	if in_debug == false:
		return
	var list_name = ["Map_BGM","Event_BGM","Battle_BGM"]
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
	var list
	var is_true = false # レジューム処理が入るか入らないか
	list = bgm_node_list[type]
	if not bgm_type == "":
		if not type == bgm_type:
			bgm_stop(bgm_node_list[bgm_type])
	for i in list.size(): # 直近で再生したか見る
		var node = list[i] # リストからノードを取得する
		if node.stream: # ノードにリソースが入っているか
			if node.stream.resource_path == path: # ノードのリソースと今回再生したいリソースが同じか
				is_true = true # 同じなので新規再生の処理を挟まなくする
				if node.stream_paused: # ノードがポーズ中か
						var node_2 = list[-1] # リストで一番最近再生したノードを取得する
						if node_2 == node: # 同じだったらこれ以降の処理は不要
							break
						if node_2.playing: 
							bgm_fade(node_2, "out") # 再生されていたら止める
						bgm_fade(node,"in") 
						node.stream_paused = false # 再生する
						list.erase(node) # リストから削除して
						list.append(node) # 一番最近再生したことにする
						break
				else: # ポーズ中なら無視する
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
			await get_tree().create_tween().tween_property(node, "volume_db", -1, 3).finished # ３秒かけて音を大きくする
		"out":
			if node.volume_db < -1:
				return
			await get_tree().create_tween().tween_property(node, "volume_db", -50, 3).finished # ３秒かけて音を小さくする
			node.stream_paused = true # ポーズモードにする

func bgm_stop(list):
	var node = list[-1] # 再生するとしたら一番最近のにあるので取得する
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

