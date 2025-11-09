extends Node

# RECT SPAWN ZONES (x, y, width, height)
const spawn_zones := {
	"lobster": Rect2(300, 600, 400, 300),
	"shrimp": Rect2(1000, 450, 350, 350),
	"shark": Rect2(1500, 200, 500, 500),
	"starfish": Rect2(800, 900, 300, 200),
	"tuna": Rect2(1200, 50, 400, 300),
	"seaweed": Rect2(50, 200, 300, 800)
}

# Preload animal scenes
const scenes := {
	"lobster": preload("res://Scenes/Lobster.tscn"),
	"shrimp": preload("res://Scenes/Shrimp.tscn"),
	"shark": preload("res://Scenes/Shark.tscn"),
	"starfish": preload("res://Scenes/Starfish.tscn"),
	"tuna": preload("res://Scenes/Tuna.tscn"),
	"seaweed": preload("res://Scenes/Seaweed.tscn")
}

# How many of each to spawn
const spawn_counts := {
	"lobster": 5,
	"shrimp": 7,
	"shark": 2,
	"starfish": 3,
	"tuna": 4,
	"seaweed": 10
}

func _ready() -> void:
	randomize()
	spawn_all()


func spawn_all() -> void:
	for type in scenes.keys():
		var count: int = spawn_counts[type]
		for i in count:
			spawn_in_zone(type)


func spawn_in_zone(type: String) -> void:
	var scene: PackedScene = scenes[type]
	var animal := scene.instantiate()

	var zone: Rect2 = spawn_zones[type]

	# choose a random point inside Rect2
	animal.global_position = Vector2(
		zone.position.x + randf() * zone.size.x,
		zone.position.y + randf() * zone.size.y
	)

	get_tree().current_scene.add_child(animal)
	print("Spawned", type, "at", animal.global_position)
