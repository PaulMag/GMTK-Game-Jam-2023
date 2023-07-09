extends Node2D

class_name Dungeon


@onready var flag: Flag = $Flag
@onready var hero: Hero = $Hero

var totalMonsters: int


func _ready():
	hero.flag = flag
	totalMonsters = getAllMonsters().size()

func getAllMonsters() -> Array[Monster]:
	var nodes = get_children()
	var monsters: Array[Monster]
	for node in nodes:
		if is_instance_valid(node) and (node is Monster):
			monsters.append(node)
	return monsters
