class_name EnemyAI extends Node

# Enemy AI - Chase behavior
# Attach to an enemy CharacterBody2D to make it chase the player

enum State { IDLE, CHASE, ATTACK }

@export var chase_speed: float = 150.0
@export var detection_range: float = 300.0
@export var attack_range: float = 50.0
@export var attack_damage: float = 1.0
@export var attack_cooldown: float = 1.0

var current_state: State = State.IDLE
var target: Node2D = null
var attack_timer: float = 0.0

func _ready():
	print("EnemyAI attached to: ", get_parent().name)

func _physics_process(delta):
	# Update attack cooldown
	if attack_timer > 0:
		attack_timer -= delta

	# Find player
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		current_state = State.IDLE
		return

	var parent = get_parent()
	if parent == null or not parent is CharacterBody2D:
		return

	var distance = parent.global_position.distance_to(player.global_position)

	# State machine
	match current_state:
		State.IDLE:
			if distance < detection_range:
				target = player
				current_state = State.CHASE

		State.CHASE:
			if distance > detection_range * 1.5:
				# Lost target
				target = null
				current_state = State.IDLE
			elif distance < attack_range:
				current_state = State.ATTACK
			else:
				# Move towards player
				var direction = parent.global_position.direction_to(target.global_position)
				parent.velocity = direction * chase_speed
				parent.move_and_slide()

		State.ATTACK:
			if distance > attack_range * 1.5:
				current_state = State.CHASE
			else:
				# Attack if cooldown is ready
				if attack_timer <= 0:
					_perform_attack()
				# Stop moving while attacking
				parent.velocity = Vector2.ZERO

func _perform_attack():
	if target == null:
		return

	attack_timer = attack_cooldown

	# Deal damage to player if they have take_damage method
	if target.has_method("take_damage"):
		target.take_damage(attack_damage)
		print("Enemy attacked player for ", attack_damage, " damage!")

func get_state_name() -> String:
	match current_state:
		State.IDLE:
			return "IDLE"
		State.CHASE:
			return "CHASE"
		State.ATTACK:
			return "ATTACK"
	return "UNKNOWN"
