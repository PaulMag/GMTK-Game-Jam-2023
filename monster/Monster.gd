extends CharacterBody2D

class_name Monster


const SPEED := 300.0
const JUMP_VELOCITY := -400.0
var GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var collisionShape: CollisionShape2D = $CollisionShape2D
@onready var deathTimer: Timer = $DeathTimer


func _ready() -> void:
	$AnimatedSprite2D.play()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump()

	var direction: float = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func jump() -> void:
	velocity.y = JUMP_VELOCITY

func die() -> void:
	scale.y *= 0.5
	rotation_degrees = randf_range(45, 315)
	collisionShape.queue_free()  # Start falling through the ground
	deathTimer.start()

func _on_death_timer_timeout():
	queue_free()
