class_name SpellData extends Resource

# Spell identification
@export var spell_name: String
@export var transcription: String  # For typing cast (e.g., "IGNIS MAJORIS")
@export var hotkey_index: int = -1  # 0-3 for slots 1-4, -1 = none

# Behavior
@export_enum("projectile", "raycast", "instant") var behavior_type: String = "projectile"
@export var projectile_scene: PackedScene
@export var impact_effect: PackedScene

# Damage scaling
@export var base_damage: float = 10.0
@export var max_damage: float = 30.0

# Movement (for projectiles)
@export var speed: float = 400.0
@export var max_speed: float = 800.0
@export var max_range: float = 1500.0
@export var lifetime: float = 5.0

# Charging
@export var supports_charging: bool = true
@export var max_charge_time: float = 3.0

# Visual
@export var icon: Texture2D
