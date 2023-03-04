extends HBoxContainer
@onready var content = $Content
@onready var author = $Author
@onready var license = $License
@onready var hpurl = $HPURL

signal License_open
signal HP_open

var credit_example = {
	"Content" : "Sirakaba Game Template",
	"Author" : "SirakabaBiome",
	"License_type" : "MITLicense",
	"License_URL" : "https://opensource.org/license/mit/",
	"HP_URL" : "https://birchgame.org/"
}

func _ready():
	pass

func slot_set(data):
	if not data["Content"] == "NULL":
		content.text = data["Content"]
	else:
		content.hide()
	if not data["Author"] == "NULL":
		author.text = data["Author"]
	else:
		author.hide()
	license.text = data["License_type"]
	var license_url
	match data["License_type"]:
		"MITLicense":
			license_url = "https://opensource.org/license/mit/"
		_:
			license_url = data["License_URL"]
	license.pressed.connect(_pressed_url_open.bind("License"))
	hpurl.pressed.connect(_pressed_url_open.bind("HP"))

func _pressed_url_open(type):
	match type:
		"License":
			emit_signal("License_open")
		"HP":
			emit_signal("HP_open")
