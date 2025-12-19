extends GutTest

var Player = preload("res://scenes/player/player.tscn")

func test_player_loads():
	assert_not_null(Player, "Player scene should load")

func test_player_has_charging_variables():
	var player = Player.instantiate()
	add_child_autofree(player)

	assert_true("is_charging_spell" in player, "Player should have is_charging_spell variable")
	assert_true("spell_charge_time" in player, "Player should have spell_charge_time variable")
	assert_true("spell_hotkey_pressed" in player, "Player should have spell_hotkey_pressed variable")
	assert_true("active_spell" in player, "Player should have active_spell variable")

func test_player_has_charging_methods():
	var player = Player.instantiate()
	add_child_autofree(player)

	assert_true(player.has_method("_start_hotkey_charge"), "Player should have _start_hotkey_charge method")
	assert_true(player.has_method("_release_spell"), "Player should have _release_spell method")
	assert_true(player.has_method("_update_charge_indicator"), "Player should have _update_charge_indicator method")
	assert_true(player.has_method("get_charge_percent"), "Player should have get_charge_percent method")

func test_player_has_charge_indicator():
	var player = Player.instantiate()
	add_child_autofree(player)

	var charge_indicator = player.get_node_or_null("ChargeIndicator")
	assert_not_null(charge_indicator, "Player should have ChargeIndicator child")

func test_charge_indicator_initially_hidden():
	var player = Player.instantiate()
	add_child_autofree(player)

	var charge_indicator = player.get_node_or_null("ChargeIndicator")
	if charge_indicator:
		assert_false(charge_indicator.visible, "Charge indicator should be hidden initially")

func test_initial_charge_state():
	var player = Player.instantiate()
	add_child_autofree(player)

	assert_false(player.is_charging_spell, "Player should not be charging initially")
	assert_eq(player.spell_charge_time, 0.0, "Charge time should be 0 initially")
	assert_eq(player.spell_hotkey_pressed, -1, "No hotkey should be pressed initially")
	assert_null(player.active_spell, "No active spell initially")

func test_get_charge_percent_at_zero():
	var player = Player.instantiate()
	add_child_autofree(player)

	assert_eq(player.get_charge_percent(), 0.0, "Charge percent should be 0 initially")

func test_max_charge_time_constant():
	var player = Player.instantiate()
	add_child_autofree(player)

	assert_eq(player.MAX_CHARGE_TIME, 3.0, "Max charge time should be 3.0 seconds")
