extends CharacterBody2D

class_name Hero


const SPEED := 200.0
const JUMP_VELOCITY := -400.0
const JUMP_VELOCITY_STOMP := -250.0
var GRAVITY: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var groundDetector: Area2D = $GroundDetector
@onready var jumpBlockedDetector: Area2D = $JumpBlockedDetector
@onready var flipTimer: Timer = $FlipTimer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction: float = 1.0


func _ready() -> void:
	$AnimatedSprite2D.play()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	elif (is_on_wall() or (not groundDetector.has_overlapping_bodies())):
		if jumpBlockedDetector.has_overlapping_bodies():
			flip()
		else:
			jump()

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func jump() -> void:
	velocity.y = JUMP_VELOCITY

func stompJump() -> void:
	velocity.y = JUMP_VELOCITY_STOMP

func flip() -> void:
	if is_on_floor():
		direction *= -1
		transform.x *= -1

func _on_flip_timer_timeout() -> void:
	flip()
	flipTimer.wait_time = randf_range(0.5, 4)

func _on_stomp_detector_body_entered(body: Monster) -> void:
	stompJump()
	body.die()
