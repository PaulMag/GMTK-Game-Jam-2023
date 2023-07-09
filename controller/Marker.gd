extends Node2D

class_name Marker

const OFFSET := -70.0
const AMPLITUDE := 10.0
const SPEED := 2 * PI
const COLOR := Color.GREEN
const COLOR_DEAD := Color.RED
const COLOR_SWITCH := Color.YELLOW

@onready var sprite = $Sprite2D

var markerMotion := 0.0
var isAlive := true


func _process(delta):
	if isAlive:
		sprite.position.y = OFFSET + sin(Time.get_unix_time_from_system() * SPEED) * AMPLITUDE

func makeAlive():
	isAlive = true
#	sprite.modulate = COLOR

func makeDead():
	isAlive = false
#	sprite.modulate = COLOR_DEAD

func makeSwitch():
	sprite.scale = 0.75
#	sprite.modulate = COLOR_SWITCH
