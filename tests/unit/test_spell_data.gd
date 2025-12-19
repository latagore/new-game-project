extends GutTest

var fireball_resource = preload("res://resources/spells/fireball.tres")
var lightning_resource = preload("res://resources/spells/lightning.tres")

func test_fireball_resource_loads():
	assert_not_null(fireball_resource, "Fireball resource should load")

func test_lightning_resource_loads():
	assert_not_null(lightning_resource, "Lightning resource should load")

func test_fireball_is_spell_data():
	assert_true(fireball_resource is SpellData, "Fireball should be a SpellData resource")

func test_lightning_is_spell_data():
	assert_true(lightning_resource is SpellData, "Lightning should be a SpellData resource")

func test_fireball_name():
	assert_eq(fireball_resource.spell_name, "Fireball", "Fireball name should be 'Fireball'")

func test_lightning_name():
	assert_eq(lightning_resource.spell_name, "Lightning", "Lightning name should be 'Lightning'")

func test_fireball_behavior_type():
	assert_eq(fireball_resource.behavior_type, "projectile", "Fireball should be projectile type")

func test_lightning_behavior_type():
	assert_eq(lightning_resource.behavior_type, "raycast", "Lightning should be raycast type")

func test_fireball_hotkey():
	assert_eq(fireball_resource.hotkey_index, 0, "Fireball should be on hotkey 0 (key 1)")

func test_lightning_hotkey():
	assert_eq(lightning_resource.hotkey_index, 1, "Lightning should be on hotkey 1 (key 2)")

func test_fireball_has_scene():
	assert_not_null(fireball_resource.projectile_scene, "Fireball should have a projectile scene")

func test_lightning_has_scene():
	assert_not_null(lightning_resource.projectile_scene, "Lightning should have a projectile scene")

func test_fireball_base_damage():
	assert_eq(fireball_resource.base_damage, 15.0, "Fireball base damage should be 15")

func test_lightning_base_damage():
	assert_eq(lightning_resource.base_damage, 30.0, "Lightning base damage should be 30")
