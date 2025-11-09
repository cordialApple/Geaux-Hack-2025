extends Node2D

# Preload your animal scenes
@export var seaweed_scene: PackedScene
@export var shark_scene: PackedScene

# Spawn settings
@export var spawn_area_size: Vector2 = Vector2(2000, 2000)
@export var seaweed_spawn_interval: float = 2.0  # Spawn seaweed every 2 seconds
@export var shark_spawn_interval: float = 10.0   # Spawn shark every 10 seconds
@export var max_seaweed: int = 50  # Maximum seaweed on map
@export var max_sharks: int = 10   # Maximum sharks on map

var seaweed_timer: float = 0.0
var shark_timer: float = 0.0
var seaweed_count: int = 0
var shark_count: int = 0

func _ready():
	# Spawn some initial seaweed
	for i in range(10):
		spawn_seaweed()
	
	# Spawn 1-2 initial sharks
	for i in range(2):
		spawn_shark()

func _process(delta: float) -> void:
	# Seaweed spawning timer
	seaweed_timer += delta
	if seaweed_timer >= seaweed_spawn_interval and seaweed_count < max_seaweed:
		spawn_seaweed()
		seaweed_timer = 0.0
	
	# Shark spawning timer
	shark_timer += delta
	if shark_timer >= shark_spawn_interval and shark_count < max_sharks:
		spawn_shark()
		shark_timer = 0.0

func spawn_seaweed():
	if seaweed_scene == null:
		return
		
	var seaweed = seaweed_scene.instantiate()
	seaweed.spawn_area_size = spawn_area_size
	
	# Random spawn position
	seaweed.position = Vector2(
		randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2),
		randf_range(-spawn_area_size.y / 2, spawn_area_size.y / 2)
	)
	
	add_child(seaweed)
	seaweed_count += 1
	
	# Connect to track when it dies
	seaweed.tree_exiting.connect(_on_seaweed_removed)

func spawn_shark():
	if shark_scene == null:
		return
		
	var shark = shark_scene.instantiate()
	shark.spawn_area_size = spawn_area_size
	
	# Spawn sharks farther from center
	var distance = randf_range(500, spawn_area_size.x / 2)
	var angle = randf() * TAU
	shark.position = Vector2(cos(angle), sin(angle)) * distance
	
	add_child(shark)
	shark_count += 1
	
	# Connect to track when it dies
	shark.tree_exiting.connect(_on_shark_removed)

func _on_seaweed_removed():
	seaweed_count -= 1

func _on_shark_removed():
	shark_count -= 1
