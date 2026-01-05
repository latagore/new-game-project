# Godot Quirks & Gotchas

A living document of Godot 4.x syntax quirks and common pitfalls discovered during development. **Update this file as new quirks are found.**

---

## Node Naming

### Dynamically created nodes don't auto-name
When creating nodes with `.new()`, they don't get a predictable name for `get_node()` paths.

```gdscript
# BAD - VBoxContainer won't be named "VBoxContainer"
var vbox = VBoxContainer.new()
panel.add_child(vbox)
var label = panel.get_node("VBoxContainer/MyLabel")  # FAILS - path not found

# GOOD - explicitly set the name
var vbox = VBoxContainer.new()
vbox.name = "VBoxContainer"
panel.add_child(vbox)
var label = panel.get_node("VBoxContainer/MyLabel")  # Works
```

---

## Typed Arrays

### Cannot directly assign untyped arrays to typed array properties
When a class property is declared as a typed array (e.g., `Array[Vector2]`), you cannot assign a regular untyped array literal to it. This commonly occurs in tests.

```gdscript
# Class definition
class_name GestureRecognizer
var points: Array[Vector2] = []

# BAD - assigning untyped array to typed property
recognizer.points = [Vector2(0, 0), Vector2(100, 100)]  # ERROR!

# GOOD - use .clear() and .append()
recognizer.points.clear()
recognizer.points.append(Vector2(0, 0))
recognizer.points.append(Vector2(100, 100))

# GOOD (alternative) - type the array inline
recognizer.points = [Vector2(0, 0), Vector2(100, 100)] as Array[Vector2]
```

---

## UI / Control Nodes

### Anchors don't work under Node2D
Control node anchors (for responsive positioning) only work when the parent is also a Control node. Under Node2D, anchors are ignored.

```gdscript
# BAD - SpellHotbar anchors ignored, appears at (0,0)
# Node2D
#   └── SpellHotbar (Control with anchors)

# GOOD - wrap in CanvasLayer for UI overlay
# Node2D
#   └── CanvasLayer
#         └── SpellHotbar (Control with anchors)  # Anchors work!
```

---

## Input Handling

### Input action names vs actual keys
Built-in action names like `ui_focus_next` map to Tab, not what you might expect. For specific keys, use keycode checks.

```gdscript
# BAD - ui_focus_next is Tab key, not F
if event.is_action_pressed("ui_focus_next"):
    cast_fireball()  # Never triggers on F key

# GOOD - direct keycode check
if event is InputEventKey and event.pressed and event.keycode == KEY_F:
    cast_fireball()
```

### Event-based vs continuous input for charging
`_input()` fires once on press. For hold-to-charge mechanics, use continuous checking in `_physics_process()`.

```gdscript
# BAD - fires immediately, no charging possible
func _input(event):
    if event.is_action_pressed("spell_1"):
        cast_spell()  # Fires instantly on press

# GOOD - allows hold-to-charge
func _physics_process(delta):
    if Input.is_action_pressed("spell_1"):
        charge_time += delta
    elif charge_time > 0:
        release_spell(charge_time)
        charge_time = 0
```

---

## Signals & Connections

### Signal callbacks with wrong signature fail silently
If your callback has the wrong number of parameters, the connection silently fails or crashes at runtime.

```gdscript
# Signal emits: signal damaged(amount: int, source: Node)

# BAD - wrong signature, fails silently
func _on_damaged():
    print("ouch")

# GOOD - match the signal signature
func _on_damaged(amount: int, source: Node):
    print("took ", amount, " damage from ", source)
```

---

## Resources

### Resource paths are case-sensitive on export
Works in editor on macOS/Windows, fails on Linux or in exported builds.

```gdscript
# BAD - might work in editor, fails on export
var spell = load("res://Resources/Spells/Fireball.tres")

# GOOD - consistent lowercase paths
var spell = load("res://resources/spells/fireball.tres")
```

---

## Physics & Collision

### Area2D signals require monitoring enabled
`area_entered` and `body_entered` signals only fire if `monitoring = true`.

```gdscript
# In _ready() or inspector, ensure:
$Hitbox.monitoring = true
$Hitbox.monitorable = true  # If other areas need to detect this one
```

---

## Common Null Reference Scenarios

### @onready vars are null in _init()
`@onready` variables aren't set until `_ready()` is called.

```gdscript
@onready var sprite = $Sprite2D

func _init():
    sprite.modulate = Color.RED  # CRASH - sprite is null

func _ready():
    sprite.modulate = Color.RED  # Works
```

### get_tree() is null before added to scene
Can't access the scene tree until the node is part of it.

```gdscript
func _init():
    get_tree().reload_current_scene()  # CRASH

func _ready():
    get_tree().reload_current_scene()  # Works
```

---

*Add new quirks as you discover them!*
