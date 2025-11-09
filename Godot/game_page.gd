extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Name.text = Global.player_name
	print(Global.player_name)

func _on_lobster_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/start_game.tscn")
