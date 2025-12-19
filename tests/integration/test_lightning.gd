extends GutTest

var LightningBolt = preload("res://scenes/spells/effects/lightning_bolt.tscn")

func test_lightning_loads():
	assert_not_null(LightningBolt, "Lightning scene should load")

func test_lightning_instantiates():
	var lb = LightningBolt.instantiate()
	assert_not_null(lb, "Lightning should instantiate")
	lb.queue_free()

func test_lightning_has_initialize_method():
	var lb = LightningBolt.instantiate()
	assert_true(lb.has_method("initialize"), "Lightning should have initialize method")
	lb.queue_free()

func test_lightning_has_calculate_damage_method():
	var lb = LightningBolt.instantiate()
	assert_true(lb.has_method("_calculate_damage"), "Lightning should have _calculate_damage method")
	lb.queue_free()

func test_lightning_base_damage():
	var lb = LightningBolt.instantiate()
	add_child_autofree(lb)
	lb.power = 1.0
	var damage = lb._calculate_damage()
	assert_eq(damage, 30.0, "Base damage should be 30 at power 1.0")

func test_lightning_max_damage():
	var lb = LightningBolt.instantiate()
	add_child_autofree(lb)
	lb.power = 3.0
	var damage = lb._calculate_damage()
	assert_eq(damage, 90.0, "Max damage should be 90 at power 3.0")

func test_lightning_mid_damage():
	var lb = LightningBolt.instantiate()
	add_child_autofree(lb)
	lb.power = 2.0
	var damage = lb._calculate_damage()
	assert_eq(damage, 60.0, "Mid damage should be 60 at power 2.0")

func test_lightning_has_main_bolt():
	var lb = LightningBolt.instantiate()
	add_child_autofree(lb)
	assert_not_null(lb.get_node_or_null("MainBolt"), "Lightning should have MainBolt child")

func test_lightning_has_glow_bolt():
	var lb = LightningBolt.instantiate()
	add_child_autofree(lb)
	assert_not_null(lb.get_node_or_null("GlowBolt"), "Lightning should have GlowBolt child")

func test_lightning_has_impact_particles():
	var lb = LightningBolt.instantiate()
	add_child_autofree(lb)
	assert_not_null(lb.get_node_or_null("ImpactParticles"), "Lightning should have ImpactParticles child")
