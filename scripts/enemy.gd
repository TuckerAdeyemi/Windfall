extends Resource

class_name Enemy

@export var portrait: Texture
@export var name: String
@export var level: int
@export var hp: int
@export var max_hp: int
@export var mp: int
@export var max_mp: int
@export var str : int
@export var mag : int
@export var spd : int
@export var def : int
@export var res : int
@export var luck : int
@export var exp_given: int
@export var money_total: int
#@export var items_given: int
@export_file("*.png") var sprite_path: String = "res://assets/sprites/enemy/windfall-mon-slime-removebg-preview.png"
@export var battle_theme : AudioStreamOggVorbis = preload("res://music/battle.ogg")
@export var is_player: bool = false
@export var ai_script: EnemyAI

# In your enemy.gd script or resource:
@export var elemental_weaknesses = {
	"Fire": 1.0,
	"Wind": 1.0,
	"Ice": 1.0,
	"Lightning": 1.0,
	"Earth": 1.0,
	"Light": 1.0,
	"Dark": 1.0,
	"Time": 1.0,
	"Neutral": 1.0  
}

