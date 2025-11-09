extends CharacterBody2D

@export var hp: int
@export var level: int
@export var runAway: bool
@export var chase: bool
var rng = RandomNumberGenerator.new()

var ROTATION_OFFSET = 270
var ROTATION_SPEED = 20
var wanderTimer = 0

func autoMove() ->void:
	rotate(rng.randf_range(0,2))
	var rotationVector = Vector2.ZERO
	rotationVector.normalized()
	var target_angle = input_vector.angle()
	rotation = lerp_angle(rotation, target_angle + ROTATION_OFFSET, ROTATION_SPEED * delta) 
	var alignment = cos(rotation - (target_angle + ROTATION_OFFSET))
	velocity = input_vector * SPEED * max(alignment, 0)
	
func detectPrey() -> void:
	runAway = true;

func _ready() -> void:
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	wanderTimer -= delta
