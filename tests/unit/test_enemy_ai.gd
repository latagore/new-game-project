extends GutTest

var ChasingEnemy = preload("res://scenes/enemies/chasing_enemy.tscn")

func test_chasing_enemy_loads():
	assert_not_null(ChasingEnemy, "Chasing enemy scene should load")

func test_chasing_enemy_instantiates():
	var enemy = ChasingEnemy.instantiate()
	assert_not_null(enemy, "Chasing enemy should instantiate")
	enemy.queue_free()

func test_chasing_enemy_has_ai():
	var enemy = ChasingEnemy.instantiate()
	add_child_autofree(enemy)

	var ai = enemy.get_node_or_null("EnemyAI")
	assert_not_null(ai, "Chasing enemy should have EnemyAI child")

func test_enemy_ai_is_correct_class():
	var enemy = ChasingEnemy.instantiate()
	add_child_autofree(enemy)

	var ai = enemy.get_node_or_null("EnemyAI")
	if ai:
		assert_true(ai is EnemyAI, "EnemyAI should be of class EnemyAI")

func test_enemy_ai_default_state():
	var enemy = ChasingEnemy.instantiate()
	add_child_autofree(enemy)

	var ai = enemy.get_node_or_null("EnemyAI")
	if ai:
		assert_eq(ai.current_state, EnemyAI.State.IDLE, "AI should start in IDLE state")

func test_enemy_ai_has_chase_speed():
	var enemy = ChasingEnemy.instantiate()
	add_child_autofree(enemy)

	var ai = enemy.get_node_or_null("EnemyAI")
	if ai:
		assert_gt(ai.chase_speed, 0, "AI should have positive chase speed")

func test_enemy_ai_has_detection_range():
	var enemy = ChasingEnemy.instantiate()
	add_child_autofree(enemy)

	var ai = enemy.get_node_or_null("EnemyAI")
	if ai:
		assert_gt(ai.detection_range, 0, "AI should have positive detection range")

func test_enemy_ai_has_attack_range():
	var enemy = ChasingEnemy.instantiate()
	add_child_autofree(enemy)

	var ai = enemy.get_node_or_null("EnemyAI")
	if ai:
		assert_gt(ai.attack_range, 0, "AI should have positive attack range")

func test_enemy_ai_get_state_name():
	var enemy = ChasingEnemy.instantiate()
	add_child_autofree(enemy)

	var ai = enemy.get_node_or_null("EnemyAI")
	if ai:
		assert_eq(ai.get_state_name(), "IDLE", "Initial state name should be IDLE")

func test_chasing_enemy_in_enemies_group():
	var enemy = ChasingEnemy.instantiate()
	add_child_autofree(enemy)

	assert_true(enemy.is_in_group("enemies"), "Chasing enemy should be in 'enemies' group")
