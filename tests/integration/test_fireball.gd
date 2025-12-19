extends GutTest

var Fireball = preload("res://scenes/spells/projectiles/fireball.tscn")

func test_fireball_loads():
	assert_not_null(Fireball, "Fireball scene should load")

func test_fireball_instantiates():
	var fb = Fireball.instantiate()
	assert_not_null(fb, "Fireball should instantiate")
	fb.queue_free()

func test_fireball_has_initialize_method():
	var fb = Fireball.instantiate()
	assert_true(fb.has_method("initialize"), "Fireball should have initialize method")
	fb.queue_free()

func test_fireball_moves_in_direction():
	var fb = Fireball.instantiate()
	add_child_autofree(fb)
	fb.position = Vector2.ZERO
	fb.initialize(Vector2.RIGHT, 400, 1.0, 1.0)

	# Wait for process frames (fireball uses _process, not _physics_process)
	await wait_process_frames(10)

	assert_gt(fb.position.x, 0, "Fireball should move right")
	assert_almost_eq(fb.position.y, 0.0, 10.0, "Fireball should stay near y=0")

func test_fireball_moves_in_custom_direction():
	var fb = Fireball.instantiate()
	add_child_autofree(fb)
	fb.position = Vector2.ZERO
	fb.initialize(Vector2.DOWN, 400, 1.0, 1.0)

	await wait_process_frames(10)

	assert_gt(fb.position.y, 0, "Fireball should move down")
	assert_almost_eq(fb.position.x, 0.0, 10.0, "Fireball should stay near x=0")

func test_fireball_has_correct_collision_layer():
	var fb = Fireball.instantiate()
	add_child_autofree(fb)

	# Layer 2 = bit 1 (0-indexed), so collision_layer should be 2
	assert_eq(fb.collision_layer, 2, "Fireball should be on collision layer 2")

func test_fireball_has_correct_collision_mask():
	var fb = Fireball.instantiate()
	add_child_autofree(fb)

	# Mask 4 = bit 2 (0-indexed), detects hurtboxes on layer 4
	assert_eq(fb.collision_mask, 4, "Fireball should have collision mask 4")

func test_fireball_base_damage():
	var fb = Fireball.instantiate()
	add_child_autofree(fb)
	fb.initialize(Vector2.RIGHT, 400, 1.0, 1.0)

	# Access the damage calculation
	var damage = fb._calculate_damage()
	assert_eq(damage, 15.0, "Base damage should be 15 at power 1.0")

func test_fireball_max_damage():
	var fb = Fireball.instantiate()
	add_child_autofree(fb)
	fb.initialize(Vector2.RIGHT, 400, 3.0, 1.0)

	var damage = fb._calculate_damage()
	assert_eq(damage, 45.0, "Max damage should be 45 at power 3.0")

func test_fireball_mid_damage():
	var fb = Fireball.instantiate()
	add_child_autofree(fb)
	fb.initialize(Vector2.RIGHT, 400, 2.0, 1.0)

	var damage = fb._calculate_damage()
	assert_eq(damage, 30.0, "Mid damage should be 30 at power 2.0")
