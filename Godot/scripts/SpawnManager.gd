extends Node

@export var bot_scene: PackedScene = preload("res://Scenes/Lobster.tscn")
@export var spawn_interval: float = 3.0
@export var spawn_radius: float = 2000.0

@onready var tilemap = get_node_or_null("TileMap")

var _spawn_timer: float = 0.0

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
		"scene": preload("res://Scenes/shark.tscn"),
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
		"scene": preload("res://Scenes/seaweed.tscn"),
		"default_spawn": 10,
		"cap": 40,
		"rate": 0.9
	}
}

func _ready() -> void:
	randomize()
	if tilemap:
		spawn_animals_from_map()

func _process(delta: float) -> void:
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = spawn_interval
		_replenish_bots()

func _replenish_bots() -> void:
	var g = get_node_or_null("/root/Global")
	if not g:
		return
	var target: int = g.bot_target_count
	var current: int = g.get_bot_count()
	var deficit: int = target - current
	for i in deficit:
		_spawn_bot()

func _spawn_bot() -> void:
	var animal = bot_scene.instantiate()
	if "is_bot" in animal:
		animal.is_bot = true
	if "is_player" in animal:
		animal.is_player = false
	animal.global_position = Vector2(
		randf_range(-spawn_radius, spawn_radius),
		randf_range(-spawn_radius, spawn_radius)
	)
	get_tree().current_scene.add_child(animal)

func spawn_animals_from_map() -> void:
	if not tilemap:
		return
	for obj: Node in tilemap.get_children():
		if not obj.has_meta("type"):
			continue

		var type: String = obj.get_meta("type")

		if not scenes.has(type):
			continue

		var zone_rate: float = obj.get_meta("spawn_rate") if obj.has_meta("spawn_rate") else scenes[type]["rate"]
		if randf() > zone_rate:
			continue

		var spawn_amount: int = obj.get_meta("max_spawns") if obj.has_meta("max_spawns") else scenes[type]["default_spawn"]

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

	var pos: Vector2 = zone_node.global_position
	var size: Vector2 = zone_node.size

	animal.global_position = Vector2(
		pos.x + randf() * size.x,
		pos.y + randf() * size.y
	)

	get_tree().current_scene.add_child(animal)
	animal.add_to_group(type)

func get_population(type: String) -> int:
	var list := get_tree().get_nodes_in_group(type)
	return list.size()
