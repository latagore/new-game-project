extends Node2D

const SPAWN_BATCH_SIZE = 50
const INITIAL_OBJECT_COUNT = 200

var physics_object_scene = preload("res://scenes/experiments/performance_tests/physics_test_object.tscn")
var object_count = 0
var objects_array = []
var total_kinetic_energy = 0.0

@onready var fps_label = $CanvasLayer/FPSLabel
@onready var control_label = $CanvasLayer/ControlLabel
@onready var stats_label = $CanvasLayer/StatsLabel

func _ready():
	control_label.text = "[Q] Add 50  [W] Add 200  [E] Add 1000\n[A] Remove 50  [S] Remove 200  [D] Remove 1000\n[R] Reset  [SPACE] Add Impulse"
	_spawn_objects(INITIAL_OBJECT_COUNT)

func _process(_delta):
	fps_label.text = "FPS: %d\nRigidBody2D: %d" % [Engine.get_frames_per_second(), object_count]
	
	# Calculate total kinetic energy
	total_kinetic_energy = 0.0
	var active_count = 0
	for obj in objects_array:
		if obj and is_instance_valid(obj):
			var speed = obj.linear_velocity.length()
			total_kinetic_energy += speed * speed * 0.5
			if !obj.sleeping:
				active_count += 1
	
	stats_label.text = "Memory: %.2f MB\nPhysics Time: %.2f ms\nProcess Time: %.2f ms\nPhysics Bodies: %d\nCollision Pairs: %d\nKinetic Energy: %.0f\nAwake Objects: %d" % [
		OS.get_static_memory_usage() / 1024.0 / 1024.0,
		Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0,
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0,
		Performance.get_monitor(Performance.PHYSICS_2D_ACTIVE_OBJECTS),
		Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS),
		total_kinetic_energy,
		active_count
	]
	
	if Input.is_key_pressed(KEY_Q):
		_spawn_objects(SPAWN_BATCH_SIZE)
	elif Input.is_key_pressed(KEY_W):
		_spawn_objects(200)
	elif Input.is_key_pressed(KEY_E):
		_spawn_objects(1000)
	elif Input.is_key_pressed(KEY_A):
		_remove_objects(SPAWN_BATCH_SIZE)
	elif Input.is_key_pressed(KEY_S):
		_remove_objects(200)
	elif Input.is_key_pressed(KEY_D):
		_remove_objects(1000)
	elif Input.is_action_just_pressed("ui_accept"):  # SPACE
		_add_impulse_to_all()
	elif Input.is_action_just_pressed("ui_text_backspace"):  # R
		_reset()

func _spawn_objects(count: int):
	var viewport_size = get_viewport_rect().size
	for i in range(count):
		var obj = physics_object_scene.instantiate()
		add_child(obj)
		
		obj.position = Vector2(
			randf_range(100, viewport_size.x - 100),
			randf_range(100, viewport_size.y - 100)
		)
		
		objects_array.append(obj)
		object_count += 1

func _remove_objects(count: int):
	var to_remove = min(count, objects_array.size())
	for i in range(to_remove):
		if objects_array.size() > 0:
			var obj = objects_array.pop_back()
			obj.queue_free()
			object_count -= 1

func _add_impulse_to_all():
	for obj in objects_array:
		if obj and is_instance_valid(obj):
			var impulse = Vector2(randf_range(-500, 500), randf_range(-500, 500))
			obj.apply_central_impulse(impulse)

func _reset():
	for obj in objects_array:
		if obj and is_instance_valid(obj):
			obj.queue_free()
	objects_array.clear()
	object_count = 0
	_spawn_objects(INITIAL_OBJECT_COUNT)

