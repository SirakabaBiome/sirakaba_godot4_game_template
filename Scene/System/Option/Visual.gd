extends TabBar
@onready var flash = %Flash

func _ready():
	pass

func setup():
	var visual_setting = SVar.system_value["Visual"]
	flash.button_pressed = visual_setting["Flash"]
	flash_change()

func flash_change():
	if flash.button_pressed:
		flash.text = "点滅表現が許可されています"
	else:
		flash.text = "点滅表現が行われません"
	SVar.system_value_save()

func _on_flash_toggled(button_pressed):
	flash.button_pressed = button_pressed
	flash_change()
