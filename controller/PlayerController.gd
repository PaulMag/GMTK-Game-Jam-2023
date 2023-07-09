extends Node

class_name PlayerController


const RELATIVE_SPEED := 8.0
const MARKER_COLOR := Color.GREEN
const MARKER_COLOR_DEAD := Color.RED
const MARKER_COLOR_SWITCH := Color.YELLOW

@onready var camera: Camera2D = $Camera2D
@onready var marker: Marker = $Marker
@onready var markerNext: Marker = $MarkerNext
@onready var markerPrevious: Marker = $MarkerPrevious

@onready var menuScreen: CanvasLayer = $MenuScreen
@onready var scoringLabel: Label = $MenuScreen/ColorRect/ColorRect3/ScoringLabel
@onready var pauseButton: Button = $HUD/ButtonPause

var DUNGEONS = [
	preload("res://dungeon/DungeonLevel01.tscn"),
	preload("res://dungeon/DungeonLevel02.tscn"),
	preload("res://dungeon/DungeonLevel03.tscn"),
	preload("res://dungeon/DungeonLevel04.tscn"),
]

var dungeon: Dungeon
var controlledMonster: Monster
var gameIsActive := false
var focus: Vector2


func _ready() -> void:
	var zoom = float(get_viewport().size.y) / 1080
	camera.zoom = Vector2(zoom, zoom)
	get_tree().paused = true
	$MenuScreen/ColorRect/ColorRect4/HBoxContainer/ButtonLevel01.grab_focus()
	markerNext.rotation_degrees = -90
	markerNext.modulate = MARKER_COLOR_SWITCH
	markerNext.scale = Vector2(0.75, 0.75)
	markerPrevious.rotation_degrees = 90
	markerPrevious.modulate = MARKER_COLOR_SWITCH
	markerPrevious.scale = Vector2(0.75, 0.75)

func _process(delta: float) -> void:
	if controlledMonster:
		focus = controlledMonster.deathPosition if controlledMonster.isDead else controlledMonster.position

		if controlledMonster.isDead:
			marker.modulate = MARKER_COLOR_DEAD
			marker.makeDead()
		marker.position = focus

		if getAllMonsters().size() >= 2:
			var nextMonster = getMonster("next")
			markerNext.position = nextMonster.position
			var previousMonster = getMonster("previous")
			markerPrevious.position = previousMonster.position
		else:
			markerNext.visible = false
			markerPrevious.visible = false
	else:
		focus = dungeon.hero.position  # Focus on Hero if no monsters left.

	var speed = (focus.x - camera.position.x) * delta * RELATIVE_SPEED
	camera.position.x += speed

	if dungeon.flag.has_overlapping_bodies():
		gameOver()

func _physics_process(delta: float) -> void:
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
	marker.makeAlive()
	if oldMonster and oldMonster.isDead and newMonster != oldMonster:
		oldMonster.delete()
	if isAllMonstersDead():
		controlledMonster = null
		marker.visible = false

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

func isAllMonstersDead() -> bool:
	var monsters = getAllMonsters()
	if monsters.size() == 0:
		return true
	if (monsters.size() == 1) and monsters[0].isDead:
		return true
	return false


func gameOver() -> void:
	gameIsActive = false
	controlledMonster = null
	marker.visible = false
	markerNext.visible = false
	markerPrevious.visible = false
	var totalMonsterCount: int = dungeon.totalMonsters
	var stompedMonsterCount: int = totalMonsterCount - getAllMonsters().size()
	var percentageScore: int = round(float(stompedMonsterCount) / float(totalMonsterCount) * 100)
	scoringLabel.text = (
		"Game Over!\n\n%s out of %s Goombas were stomped\n\n%s %% score!"
		% [stompedMonsterCount, totalMonsterCount, percentageScore]
	)
	pauseButton.visible = false
	menuScreen.visible = true

func displayMenu() -> void:
	get_tree().paused = true
	pauseButton.text = "Resume Game (ESCAPE)"
	menuScreen.visible = true

func hideMenu() -> void:
	menuScreen.visible = false
	pauseButton.visible = true
	get_tree().paused = false
	pauseButton.text = "Pause Game (ESCAPE)"

func createNewDungeon(level: int) -> void:
	controlledMonster = null
	if dungeon:
		dungeon.queue_free()
	dungeon = DUNGEONS[level].instantiate()
	add_child(dungeon)
	marker.visible = true
	markerNext.visible = true
	markerPrevious.visible = true
	switchControlledMonster("first")
	gameIsActive = true
	hideMenu()


func _on_button_pause_pressed():
	if not gameIsActive:
		return
	if get_tree().paused:
		hideMenu()
	else:
		displayMenu()

func _on_button_level_01_pressed():
	createNewDungeon(0)

func _on_button_level_02_pressed():
	createNewDungeon(1)

func _on_button_level_03_pressed():
	createNewDungeon(2)

func _on_button_level_04_pressed():
	createNewDungeon(3)

func _on_button_quit_game_pressed():
	get_tree().quit()
