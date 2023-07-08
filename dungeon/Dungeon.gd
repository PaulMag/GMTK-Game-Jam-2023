extends Node2D

class_name Dungeon


@onready var flag: Flag = $Flag
@onready var hero: Hero = $Hero


func _ready():
	hero.flag = flag
