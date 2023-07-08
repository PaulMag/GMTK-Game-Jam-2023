extends CharacterBody2D

class_name Monster


const SPEED := 300.0
const JUMP_VELOCITY := -400.0
var GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var collisionShape: CollisionShape2D = $CollisionShape2D
@onready var deathTimer: Timer = $DeathTimer

var direction := 0.0
var isDead := false
var deathPosition: Vector2


func _ready() -> void:
	$AnimatedSprite2D.play()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func jump() -> void:
	if is_on_floor():
		velocity.y = JUMP_VELOCITY

func die() -> void:
	isDead = true
	scale.y *= 0.5
	rotation_degrees = randf_range(45, 315)
	collisionShape.queue_free()  # Start falling through the ground
	deathPosition = position

func delete() -> void:
	deathTimer.start()

func _on_death_timer_timeout():
	queue_free()
