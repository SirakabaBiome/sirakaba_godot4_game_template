extends Control

@onready var sound = $TabContainer/Sound
@onready var visual = $TabContainer/Visual

# Called when the node enters the scene tree for the first time.
func _ready():
	SVar.system_value_load()
	sound.setup()
	visual.setup()

func _on_hidden():
	SVar.system_value_save()
