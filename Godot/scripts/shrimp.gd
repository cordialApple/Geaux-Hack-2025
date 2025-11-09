extends CharacterBody2D
const SPEED = 250.0
const ROTATION_SPEED = 3.0
const ROTATION_OFFSET = deg_to_rad(270)
const e_out = 50.0
@export var animal_tier: int = 1
@export var animal_name: String = "Shrimp"
@export var is_player: bool = false
@export var spawn_area_size: Vector2 = Vector2(10000, 10000)
@export var is_spawner: bool = true
@export var initial_tuna: int = 10

var move_direction: Vector2 = Vector2.ZERO
var direction_change_timer: float = 0.0
var direction_change_interval: float = 3.0

func _ready():
	position = Vector2(
		randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2),
		randf_range(-spawn_area_size.y / 2, spawn_area_size.y / 2)
	)
	
	if is_spawner:
		for i in range(initial_tuna):
			spawn_new_tuna()
		
		# Connect the timer to spawn function
		if has_node("Timer"):
			$Timer.timeout.connect(_on_timer_timeout)
			$Timer.start()
	
	change_direction()

func _on_timer_timeout():
	spawn_new_tuna()

func change_direction():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	direction_change_timer = direction_change_interval

func die():
	queue_free()

func spawn_new_tuna():
	for i in 2:
		var new_tuna = duplicate()
		new_tuna.is_spawner = false
		new_tuna.position = Vector2(
			randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2),
			randf_range(-spawn_area_size.y / 2, spawn_area_size.y / 2)
		)
		get_parent().call_deferred("add_child", new_tuna)

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
	else:
		var input_vector = Vector2.ZERO
		input_vector.x = Input.get_axis("ui_left", "ui_right")
		input_vector.y = Input.get_axis("ui_up", "ui_down")
		
		if input_vector.length() > 0:
			input_vector = input_vector.normalized()
			
			var target_angle = input_vector.angle()
			rotation = lerp_angle(rotation, target_angle + ROTATION_OFFSET, ROTATION_SPEED * delta) 
			
			var alignment = cos(rotation - (target_angle + ROTATION_OFFSET))
			velocity = input_vector * SPEED * max(alignment, 0)
		else:
			velocity = input_vector * SPEED
	
	move_and_slide()
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider != self:
			handle_animal_collision(collider)
