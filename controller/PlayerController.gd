extends Node

class_name PlayerController


const RELATIVE_SPEED := 8.0
const MARKER_POSITION := Vector2(-15, -15 - 80)
const MARKER_AMPLITUDE := 10.0
const MARKER_SPEED := 2 * PI
const MARKER_COLOR := Color.GREEN
const MARKER_COLOR_DEAD := Color.RED

@export var controlledMonster: Monster
@onready var dungeon: Dungeon = $Dungeon
@onready var camera: Camera2D = $Camera2D
@onready var marker: TextureRect = $TextureRect

@onready var menuScreen: CanvasLayer = $MenuScreen
@onready var scoringLabel: Label = $MenuScreen/ColorRect/ColorRect3/ScoringLabel
@onready var pauseButton: Button = $HUD/ButtonPause

var markerMotion := 0.0


func _ready() -> void:
	get_tree().paused = true
	marker.modulate = MARKER_COLOR
	switchControlledMonster("first")

func _process(delta: float) -> void:
	if controlledMonster:
		var focus = controlledMonster.deathPosition if controlledMonster.isDead else controlledMonster.position
		var speed = (focus.x - camera.position.x) * delta * RELATIVE_SPEED
		camera.position.x += speed

		if controlledMonster.isDead:
			marker.modulate = MARKER_COLOR_DEAD
		else :
			markerMotion = sin(Time.get_unix_time_from_system() * 2*PI) * MARKER_AMPLITUDE
		marker.position = focus + MARKER_POSITION
		marker.position.y += markerMotion

		if dungeon.flag.has_overlapping_bodies():
			displayMenu()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(controlledMonster):
		controlledMonster = null

	if controlledMonster and (not controlledMonster.isDead):
		if Input.is_action_just_pressed("jump"):
			controlledMonster.jump()
		controlledMonster.direction = Input.get_axis("move_left", "move_right")

func _unhandled_input(event):
	if event.is_action_pressed("next_monster") and controlledMonster:
		switchControlledMonster("next")
	elif event.is_action_pressed("previous_monster") and controlledMonster:
		switchControlledMonster("previous")

func switchControlledMonster(which) -> void:
	var oldMonster := controlledMonster
	var newMonster := getMonster(which)
	controlledMonster = newMonster
	marker.modulate = MARKER_COLOR
	if oldMonster and oldMonster.isDead and newMonster != oldMonster:
		oldMonster.delete()

func getMonster(which) -> Monster:
	var monsters := getAllMonsters()
	var rank = getHorizontalRank(controlledMonster, monsters)
	if which == "previous":
		if rank == 0:
			return monsters[~0]  # Loop around to last monster
		else:
			return monsters[rank-1]
	elif which == "next":
		if (rank + 1) >= monsters.size():
			return monsters[0]  # Loop around to first monster
		else:
			return monsters[rank+1]
	elif which == "first":
		return monsters[0]
	return null

func getAllMonsters() -> Array[Monster]:
	var nodes = dungeon.get_children()
	var monsters: Array[Monster]
	for node in nodes:
		if node is Monster and ((node == controlledMonster) or (not node.isDead)):
			# Currently controlled Monster is included even if it is dead.
			monsters.append(node)
	return monsters

func getHorizontalRank(node: Node2D, nodeList: Array) -> int:
	nodeList.sort_custom(sortByHorizontalPosition)
	for i in range(nodeList.size()):
		if nodeList[i] == node:
			return i
	return -1  # Not in list. Should not happen.

func sortByHorizontalPosition(a: Node2D, b: Node2D) -> bool:
	if a.position.x < b.position.x:
		return true
	else:
		return false


func displayMenu() -> void:
	menuScreen.visible = true
	scoringLabel.text = "Game Over!\n\n%s out of your 8 Goombas were stomped" % [8 - getAllMonsters().size() + (1 if controlledMonster.isDead else 0)]
	get_tree().paused = true
	pauseButton.text = "Resume Game"

func hideMenu() -> void:
	menuScreen.visible = false
	pauseButton.visible = true
	get_tree().paused = false
	pauseButton.text = "Pause Game"


func _on_button_level_1_pressed():
	hideMenu()

func _on_button_pause_pressed():
	if get_tree().paused:
		hideMenu()
	else:
		displayMenu()
