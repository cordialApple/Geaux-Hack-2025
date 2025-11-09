extends CharacterBody2D
const SPEED = 300.0  
const ROTATION_SPEED = 3.0
const ROTATION_OFFSET = deg_to_rad(270)
@export var animal_tier: int = 4
@export var animal_name: String = "Shark"
@export var is_player: bool = false
@export var spawn_area_size: Vector2 = Vector2(10000, 10000)

var move_direction: Vector2 = Vector2.ZERO
var direction_change_timer: float = 0.0
var direction_change_interval: float = 3.0 

func _ready():
	var distance = randf_range(500, spawn_area_size.x / 2)
	var angle = randf() * TAU
	position = Vector2(cos(angle), sin(angle)) * distance
	change_direction()

func change_direction():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	direction_change_timer = direction_change_interval

func die():
	queue_free()

func handle_animal_collision(other_animal):
	if other_animal.has_method("get_tier"):
		var other_tier = other_animal.get_tier()
		
		if other_tier > animal_tier:
			die()
		elif other_tier < animal_tier:
			other_animal.die()
			
func get_tier() -> int:
	return animal_tier

func _physics_process(delta: float) -> void:
	if not is_player:
		direction_change_timer -= delta
		if direction_change_timer <= 0:
			change_direction()
		
		if move_direction.length() > 0:
			var target_angle = move_direction.angle()
			rotation = lerp_angle(rotation, target_angle + ROTATION_OFFSET, ROTATION_SPEED * delta)
			velocity = move_direction * SPEED
	
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider != self:
			handle_animal_collision(collider)
