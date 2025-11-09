extends Control
@onready var player_name = $VBoxContainer/Name

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_start_button_pressed() -> void:
	Global.player_name = player_name.text
	get_tree().change_scene_to_file("res://game_page.tscn")
	
	
