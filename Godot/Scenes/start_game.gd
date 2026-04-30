extends Control

func _on_start_button_pressed() -> void:
	Lobby.join_game()
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
