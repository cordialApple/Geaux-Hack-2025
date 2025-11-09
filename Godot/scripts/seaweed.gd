extends CharacterBody2D
const SPEED = 500.0
const ROTATION_SPEED = 5.0
const ROTATION_OFFSET = deg_to_rad(270)
const e_out = 1.0
@export var animal_tier: int = 0
@export var animal_name: String = "Seaweed"
@export var is_player: bool = false
@export var spawn_area_size: Vector2 = Vector2(10000, 10000)
@export var is_spawner: bool = false
@export var seaweed_to_spawn: int = 67

var is_dying: bool = false  # Prevent multiple death calls

func _ready():
	# Random spawn position
	position = Vector2(
		randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2),
		randf_range(-spawn_area_size.y / 2, spawn_area_size.y / 2)
	)
	
	# If this is the spawner, create initial seaweed
	if is_spawner:
		for i in range(seaweed_to_spawn):
			spawn_new_seaweed()

func die():
	if is_dying:  # Already dying, don't do it again
		return
	is_dying = true
	
	spawn_new_seaweed()
	queue_free()

func spawn_new_seaweed():
	var new_seaweed = duplicate()
	new_seaweed.is_spawner = false
	new_seaweed.is_dying = false  # Reset the flag for new seaweed
	new_seaweed.position = Vector2(
		randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2),
		randf_range(-spawn_area_size.y / 2, spawn_area_size.y / 2)
	)
	get_parent().call_deferred("add_child", new_seaweed)
	
func handle_animal_collision(other_animal):
	if is_dying:  
		return
		
	if other_animal.has_method("get_tier"):
		var other_tier = other_animal.get_tier()
		
		if other_tier > animal_tier:
			die()
		elif other_tier < animal_tier:
			other_animal.die()
			
func get_tier() -> int:
	return animal_tier

func _physics_process(delta: float) -> void:
	if is_dying:  # Stop processing if dying
		return
		
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider != self:
			handle_animal_collision(collider)
