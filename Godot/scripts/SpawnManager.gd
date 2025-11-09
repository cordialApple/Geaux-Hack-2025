extends Node

@onready var tilemap: TileMap = $TileMap

# Preload animal scenes with metadata
const scenes := {
	"lobster": {
		"scene": preload("res://Scenes/Lobster.tscn"),
		"default_spawn": 4,
		"cap": 20,
		"rate": 0.7
	},
	"shrimp": {
		"scene": preload("res://Scenes/Shrimp.tscn"),
		"default_spawn": 6,
		"cap": 25,
		"rate": 0.8
	},
	"shark": {
		"scene": preload("res://Scenes/Shark.tscn"),
		"default_spawn": 2,
		"cap": 4,
		"rate": 0.2
	},
	"starfish": {
		"scene": preload("res://Scenes/Starfish.tscn"),
		"default_spawn": 3,
		"cap": 10,
		"rate": 0.5
	},
	"tuna": {
		"scene": preload("res://Scenes/Tuna.tscn"),
		"default_spawn": 4,
		"cap": 12,
		"rate": 0.6
	},
	"seaweed": {
		"scene": preload("res://Scenes/Seaweed.tscn"),
		"default_spawn": 10,
		"cap": 40,
		"rate": 0.9
	}
}

func _ready() -> void:
	randomize()
	spawn_animals_from_map()


func spawn_animals_from_map() -> void:
	# run through each spawn zone rectangle
	for obj: Node in tilemap.get_children():
		if not obj.has_meta("type"):
			continue

		var type: String = obj.get_meta("type")

		if not scenes.has(type):
			continue

		# spawn probability determination
		var zone_rate: float = obj.get_meta("spawn_rate") if obj.has_meta("spawn_rate") else scenes[type]["rate"]
		if randf() > zone_rate:
			continue

		# spawn counts
		var spawn_amount: int = obj.get_meta("max_spawns") if obj.has_meta("max_spawns") else scenes[type]["default_spawn"]

		# population limit
		var cap: int = obj.get_meta("population_cap") if obj.has_meta("population_cap") else scenes[type]["cap"]
		if get_population(type) >= cap:
			continue

		for i in spawn_amount:
			if get_population(type) >= cap:
				break
			spawn_in_zone(type, obj)


func spawn_in_zone(type: String, zone_node: Node2D) -> void:
	var scene: PackedScene = scenes[type]["scene"]
	var animal: Node2D = scene.instantiate()

	# random position inside rectangle
	var pos: Vector2 = zone_node.global_position
	var size: Vector2 = zone_node.size

	animal.global_position = Vector2(
		pos.x + randf() * size.x,
		pos.y + randf() * size.y
	)

	# add animal to the scene
	get_tree().current_scene.add_child(animal)

	# add into a group for population control b/c we want to preserve ecosystem balance
	animal.add_to_group(type)

	print("Spawned", type, "at", animal.global_position)

# optional function, just here for the memes
func get_population(type: String) -> int:
	var list := get_tree().get_nodes_in_group(type)
	return list.size()
