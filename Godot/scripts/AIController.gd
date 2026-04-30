class_name AIController
extends RefCounted

enum State {IDLE, CHASE, FLEE}

var creature: Node2D = null
var state: int = State.IDLE
var idle_direction: Vector2 = Vector2.ZERO
var direction_timer: float = 0.0
var current_target: Node2D = null

func _init(c: Node2D = null) -> void:
	if c:
		attach(c)

func attach(c: Node2D) -> void:
	creature = c
	_pick_idle_direction()

func _pick_idle_direction() -> void:
	idle_direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
	direction_timer = creature.direction_change_interval

func get_direction(delta: float) -> Vector2:
	if creature == null:
		return Vector2.ZERO
	_update_state()
	match state:
		State.CHASE:
			if current_target and is_instance_valid(current_target):
				return (current_target.global_position - creature.global_position).normalized()
			return Vector2.ZERO
		State.FLEE:
			if current_target and is_instance_valid(current_target):
				return (creature.global_position - current_target.global_position).normalized()
			return Vector2.ZERO
		_:
			direction_timer -= delta
			if direction_timer <= 0.0:
				_pick_idle_direction()
			return idle_direction

func _update_state() -> void:
	var nearest_predator: Node2D = null
	var nearest_predator_dist: float = INF
	var nearest_prey: Node2D = null
	var nearest_prey_dist: float = INF

	for animal in creature.get_tree().get_nodes_in_group("animal"):
		if animal == creature or not is_instance_valid(animal):
			continue
		if not animal.has_method("get_tier"):
			continue
		var dist: float = creature.global_position.distance_to(animal.global_position)
		if dist > creature.detection_radius:
			continue
		var their_tier: int = animal.get_tier()
		if their_tier > creature.animal_tier:
			if dist < nearest_predator_dist:
				nearest_predator_dist = dist
				nearest_predator = animal
		elif their_tier < creature.animal_tier:
			if dist < nearest_prey_dist:
				nearest_prey_dist = dist
				nearest_prey = animal

	if nearest_predator:
		state = State.FLEE
		current_target = nearest_predator
	elif nearest_prey:
		state = State.CHASE
		current_target = nearest_prey
	else:
		state = State.IDLE
		current_target = null

func get_state_name() -> String:
	match state:
		State.IDLE:
			return "IDLE"
		State.CHASE:
			return "CHASE"
		State.FLEE:
			return "FLEE"
	return "UNKNOWN"
