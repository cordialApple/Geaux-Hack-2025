extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Name.text = Global.player_name
	print(Global.player_name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
