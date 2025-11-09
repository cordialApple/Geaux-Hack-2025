extends Node

@onready var tilemap := $TileMap

# Preload animal scenes
var SCENES := {
	"lobster": preload("res://Scenes/Lobster.tscn"),
	"shrimp": preload("res://Scenes/Shrimp.tscn"),
	"shark": preload("res://Scenes/shark.tscn"),
	"starfish": preload("res://Scenes/Starfish.tscn"),
	"tuna": preload("res://Scenes/Tuna.tscn"),
	"seaweed": preload("res://Scenes/seaweed.tscn")
}

func _ready() -> void:
	randomize()
	spawn_animals_from_map()
	
func spawn_animals_from_map() -> void:
	# TileMap contains child nodes for each rectangle object
	for object in tilemap.get_children():
		if object.has_meta("type"):
			var type: String = object.get_meta("type")
			if SCENES.has(type):
				for i in 5:
					spawn_in_zone(type, object)
				
func spawn_in_zone(type: String, zone_node: Node2D) -> void:
	var animal_scene: Node2D = SCENES[type].instantiate()
	var rect_position = zone_node.global_position
	var rect_size = zone_node.size
	var random_x  = rect_position.x + randf() * rect_size.x
	var random_y = rect_position.y + randf() * rect_size.y
	animal_scene.global_position = Vector2(random_x, random_y)
	
	get_tree().current_scene.add_child(animal_scene)
	print("Spawned", type, "at", animal_scene.global_position)
