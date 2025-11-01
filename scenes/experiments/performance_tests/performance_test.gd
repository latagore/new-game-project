extends Node2D

const SPAWN_BATCH_SIZE = 100
const INITIAL_OBJECT_COUNT = 1000

var moving_object_scene = preload("res://scenes/experiments/performance_tests/moving_test_object.tscn")
var object_count = 0
var objects_array = []

@onready var fps_label = $CanvasLayer/FPSLabel
@onready var control_label = $CanvasLayer/ControlLabel
@onready var stats_label = $CanvasLayer/StatsLabel

func _ready():
	control_label.text = "[Q] Add 100  [W] Add 1000  [E] Add 10000\n[A] Remove 100  [S] Remove 1000  [D] Remove 10000\n[R] Reset  [SPACE] Toggle Movement"
	_spawn_objects(INITIAL_OBJECT_COUNT)

func _process(_delta):
	fps_label.text = "FPS: %d\nObjects: %d" % [Engine.get_frames_per_second(), object_count]
	
	stats_label.text = "Memory: %.2f MB\nPhysics Time: %.2f ms\nProcess Time: %.2f ms" % [
		OS.get_static_memory_usage() / 1024.0 / 1024.0,
		Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000.0,
		Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0
	]
	
	# Handle input
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	
	if Input.is_key_pressed(KEY_Q):
		_spawn_objects(SPAWN_BATCH_SIZE)
	elif Input.is_key_pressed(KEY_W):
		_spawn_objects(1000)
	elif Input.is_key_pressed(KEY_E):
		_spawn_objects(10000)
	elif Input.is_key_pressed(KEY_A):
		_remove_objects(SPAWN_BATCH_SIZE)
	elif Input.is_key_pressed(KEY_S):
		_remove_objects(1000)
	elif Input.is_key_pressed(KEY_D):
		_remove_objects(10000)
	elif Input.is_action_just_pressed("ui_accept"):  # SPACE
		_toggle_movement()
	elif Input.is_action_just_pressed("ui_text_backspace"):  # R
		_reset()

func _spawn_objects(count: int):
	var viewport_size = get_viewport_rect().size
	for i in range(count):
		var obj = moving_object_scene.instantiate()
		add_child(obj)
		
		# Random position
		obj.position = Vector2(
			randf_range(0, viewport_size.x),
			randf_range(0, viewport_size.y)
		)
		
		# Random velocity
		var speed = randf_range(50, 200)
		var angle = randf_range(0, TAU)
		obj.velocity = Vector2(cos(angle), sin(angle)) * speed
		
		objects_array.append(obj)
		object_count += 1

func _remove_objects(count: int):
	var to_remove = min(count, objects_array.size())
	for i in range(to_remove):
		if objects_array.size() > 0:
			var obj = objects_array.pop_back()
			obj.queue_free()
			object_count -= 1

func _toggle_movement():
	for obj in objects_array:
		if obj and is_instance_valid(obj):
			obj.is_moving = !obj.is_moving

func _reset():
	for obj in objects_array:
		if obj and is_instance_valid(obj):
			obj.queue_free()
	objects_array.clear()
	object_count = 0
	_spawn_objects(INITIAL_OBJECT_COUNT)

