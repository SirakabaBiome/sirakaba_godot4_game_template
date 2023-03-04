extends TabBar

var credit_list
var credit_list_node = preload("res://Scene/System/Option/credit_list_.tscn")
var license_list = [{
		"Name" : "MITLicense",
		"URL" : "https://opensource.org/license/mit/"
	},
	{
		"Name" : "SILオープンフォントライセンス",
		"URL" : "https://scripts.sil.org/cms/scripts/page.php?item_id=OFL_web"
	}]
@onready var credit_slot_list = $ScrollContainer/Credit_Slot_List

func _ready():
	credit_list = example_credit()
	slot_create(credit_list)

func example_credit():
	var list_1 = {
		"Content" : "GodotEngine",
		"Author" : "NULL",
		"License_type" : "Godot License",
		"License_URL" : "https://godotengine.org/license/",
		"HP_URL" : "https://godotengine.org/"
	}
	var list_2 = {
		"Content" : "Sirakaba Game Template",
		"Author" : "SirakabaBiome",
		"License_type" : "MITLicense",
		"License_URL" : "https://opensource.org/license/mit/",
		"HP_URL" : "https://birchgame.org"
	}
	return [list_1,list_2]
# 辞書型ならなんでもいいので上のは削除しても良い

func slot_create(list):
	for i in list.size():
		var node = credit_list_node.instantiate()
		var id = i + 1
		var data = list[i]
		node.name += str(id)
		credit_slot_list.add_child(node)
		node.slot_set(data)
		var license_url = ""
		for n in license_list.size():
			var item = license_list[n]
			var license = item["Name"]
			if data["License_type"] == license:
				license_url = item["URL"]
				break
		if license_url == "":
			license_url = data["License_URL"]
		node.License_open.connect(url_open.bind(license_url))
		node.HP_open.connect(url_open.bind(data["HP_URL"]))

func url_open(url):
	OS.shell_open(url)
