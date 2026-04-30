class_name CreatureBase
extends CharacterBody2D

const ROTATION_OFFSET = deg_to_rad(270)

@export_group("Identity")
@export var animal_tier: int = 2
@export var animal_name: String = "Creature"
@export var is_player: bool = false
@export var is_bot: bool = false

@export_group("Movement")
@export var speed: float = 500.0
@export var rotation_speed: float = 5.0

@export_group("AI")
@export var detection_radius: float = 800.0
@export var direction_change_interval: float = 3.0

@export_group("Progression")
@export var exp_goal: int = 50
@export var next_animal: PackedScene
@export var e_out: float = 10.0

var current_xp: int = 0
var ai: AIController = null

func _ready() -> void:
	add_to_group("animal")
	if not is_player:
		ai = AIController.new(self)
	if is_player or is_bot:
		var g := get_node_or_null("/root/Global")
		if g and g.has_method("register_player"):
			g.register_player(self, is_bot)

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	if is_player:
		direction = _get_player_direction()
	elif ai:
		direction = ai.get_direction(delta)

	if direction.length() > 0.0:
		var target_angle: float = direction.angle()
		rotation = lerp_angle(rotation, target_angle + ROTATION_OFFSET, rotation_speed * delta)
		var alignment: float = cos(rotation - (target_angle + ROTATION_OFFSET))
		velocity = direction * speed * max(alignment, 0.0)
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider and collider != self:
			handle_animal_collision(collider)

func _get_player_direction() -> Vector2:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	if input_vector.length() > 0.0:
		return input_vector.normalized()
	return Vector2.ZERO

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body and body != self:
		handle_animal_collision(body)

func handle_animal_collision(other) -> void:
	if not other.has_method("get_tier"):
		return
	var other_tier: int = other.get_tier()
	if other_tier > animal_tier:
		die()
	elif other_tier < animal_tier:
		if other.has_method("get_e_out"):
			add_xp(int(other.get_e_out()))
		if other.has_method("die"):
			other.die()

func add_xp(amount: int) -> void:
	current_xp += amount
	if current_xp >= exp_goal:
		evolve()

func evolve() -> void:
	if not next_animal:
		return
	var new_animal = next_animal.instantiate()
	new_animal.global_position = global_position
	new_animal.rotation = rotation
	if "is_player" in new_animal:
		new_animal.is_player = is_player
	if "is_bot" in new_animal:
		new_animal.is_bot = is_bot
	get_parent().add_child(new_animal)
	queue_free()

func die() -> void:
	var g := get_node_or_null("/root/Global")
	if g and g.has_method("deregister_player"):
		g.deregister_player(self)
	print(animal_name + " died!")
	queue_free()

func get_tier() -> int:
	return animal_tier

func get_e_out() -> float:
	return e_out
