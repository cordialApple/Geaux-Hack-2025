extends CharacterBody2D

const SPEED = 500.0
const ROTATION_SPEED = 5.0
const ROTATION_OFFSET = deg_to_rad(270)

@export var animal_tier: int = 2;
@export var animal_name: String = "Lobster"
@export var is_player: bool = true

func die():
	print("Lobster died!")
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
	if is_player:
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


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != self:
		handle_animal_collision(body)
