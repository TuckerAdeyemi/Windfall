extends CharacterBody2D

class_name EnemyBase

@export var character_data: Character
@export var auto_start_battle := true
@export var battle_scene = preload("res://battle/battle.tscn")

var speed = 50
var player_chase = false
var player = null
var battle = false

# === New patrol variables ===
var patrol_speed = 20
var patrol_direction = Vector2.ZERO
var change_timer = 0.0
var change_interval = 2.0

var bodies_in_detection := []
var bodies_in_hitbox := []

func _ready():
	randomize()
	choose_new_patrol_direction()

func _physics_process(delta):
	if battle:
		return  # Freeze slime during battle prep
	
	if player_chase and player:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		move_and_slide()

		$AnimatedSprite2D.play("move_side")
		$AnimatedSprite2D.flip_h = direction.x < 0
	else:
		# === Random Patrol Logic ===
		change_timer -= delta
		if change_timer <= 0:
			choose_new_patrol_direction()

		velocity = patrol_direction * patrol_speed
		move_and_slide()
		
		if patrol_direction.y > 0:
			$AnimatedSprite2D.play("move_down")
		elif patrol_direction.y < 0:
			$AnimatedSprite2D.play("move_up")
		else:
			$AnimatedSprite2D.play("move_side")
			$AnimatedSprite2D.flip_h = patrol_direction.x < 0

func choose_new_patrol_direction():
	var angle = randf() * TAU  # full 360 degrees
	patrol_direction = Vector2(cos(angle), sin(angle)).normalized()
	change_timer = change_interval

# === Player detection ===
func _on_area_2d_body_entered(body):
	player = body
	player_chase = true

func _on_area_2d_body_exited(body):
	player = null
	player_chase = false

func _on_hitbox_body_entered(body):
	if not body.is_in_group("Player"):
		return
	battle = true

func _on_hitbox_body_exited(body):
	return
