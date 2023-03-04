extends Node

@onready var option = $UI/Option_Menu

func _ready():
	pass

func _process(delta):
	if Input.is_action_just_pressed("option_enter"):
		option_open()

func _on_menu_button_pressed():
	option_open()

func option_open():
	if SVar.in_option_enabled == false:
		return
	
	if option.visible:
		option.hide()
	else:
		option.show()
