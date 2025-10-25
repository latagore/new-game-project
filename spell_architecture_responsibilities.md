# Spell System Architecture: Responsibilities & Organization

## The Problem

**Current State Issues:**
1. Player creates casting effects (`spell_effect_scene`)
2. SpellManager creates target effects (`enemy_spell_death_effect`)
3. Effects are preloaded directly in multiple files
4. With 100+ spells, where does all this code go?

**This leads to:**
- SpellManager becoming a 5000+ line monolith
- Preloading dozens of effect scenes everywhere
- Unclear ownership of visual effects
- Difficulty finding and maintaining spell code

## The Solution: Clear Separation of Concerns

### Responsibility Model

```
┌─────────────────────────────────────────────────────────────┐
│ SPELL LIFECYCLE                                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. CASTING UI          → Validates input                   │
│     ↓                      Emits spell_cast_success         │
│                                                             │
│  2. PLAYER/CASTER       → Receives cast signal              │
│     ↓                      Creates CAST EFFECT (optional)   │
│     ↓                      Calls SpellManager.cast_spell()  │
│                                                             │
│  3. SPELL MANAGER       → Validates spell exists            │
│     ↓                      Routes to correct handler        │
│     ↓                      (instant/projectile/laser/area)  │
│                                                             │
│  4. SPELL INSTANCE      → Handles own behavior              │
│     ↓                      Creates own TRAVEL EFFECTS       │
│     ↓                      Detects collision                │
│     ↓                      Creates own IMPACT EFFECTS       │
│     ↓                      Deals damage via hitbox          │
│                                                             │
│  5. TARGET              → Receives damage                   │
│                            Creates own HIT REACTION EFFECTS │
│                            (blood, hit flash, etc.)         │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Who Creates What?

| Effect Type | Created By | Example | Reasoning |
|------------|------------|---------|-----------|
| **Cast Effect** | Caster (Player/Enemy) | Magic circle at feet, hand glow | Part of caster animation/feedback |
| **Projectile Trail** | Projectile Instance | Fire trail, ice crystals | Intrinsic to the projectile |
| **Impact Effect** | Projectile Instance | Explosion, splash | Projectile knows when/where it hits |
| **Hit Reaction** | Target (Enemy/Player) | Blood splatter, damage numbers | Target owns its damage response |
| **Area Persistent** | Spell Manager via SpellInstance | Burning ground, ice field | Long-lived effects need scene management |

### Key Principle: **"Objects manage their own visuals"**

Each object is responsible for effects that are **intrinsic to itself**, not effects on other objects.

## Organization Strategy for 100+ Spells

### Strategy 1: Data-Driven System (RECOMMENDED)

**Concept:** Spells are data resources, behaviors are reusable components

```
scripts/spells/
├── spell_data.gd              # Resource definition
├── spell_behaviors/            # Reusable behavior scripts
│   ├── projectile_behavior.gd
│   ├── homing_behavior.gd
│   ├── aoe_behavior.gd
│   └── chain_behavior.gd
└── spell_registry.gd          # Central spell database

resources/spells/              # Actual spell configurations
├── fire/
│   ├── fireball.tres
│   ├── flame_wave.tres
│   └── meteor.tres
├── ice/
│   ├── ice_shard.tres
│   └── blizzard.tres
└── lightning/
    ├── lightning_bolt.tres
    └── chain_lightning.tres

scenes/spell_visuals/          # Visual-only scenes
├── projectiles/
│   ├── fireball_visual.tscn   # Sprite + particles, NO LOGIC
│   ├── ice_shard_visual.tscn
│   └── lightning_bolt_visual.tscn
└── impacts/
    ├── fire_explosion.tscn
    ├── ice_shatter.tscn
    └── lightning_crack.tscn
```

**Example Spell Resource:**
```gdscript
# resources/spells/fire/fireball.tres (created in editor)
class_name SpellData extends Resource

@export var spell_name: String = "IGNIS SAGITTA"
@export var description: String = "Fires a bolt of flame"
@export var transcription: String = "IGNIS SAGITTA"

# Behavior
@export var behavior_type: String = "projectile"  # enum would be better
@export var behavior_script: GDScript  # The reusable behavior

# Visuals (NO LOGIC in these scenes)
@export var cast_effect: PackedScene
@export var projectile_visual: PackedScene
@export var impact_effect: PackedScene

# Properties
@export var damage: int = 15
@export var speed: float = 400
@export var lifetime: float = 3.0
@export var pierce_count: int = 0

# Casting
@export var cooldown: float = 1.0
@export var mana_cost: int = 20
```

**SpellManager becomes simple:**
```gdscript
# spell_manager.gd
extends Node

var spell_registry: Dictionary = {}

func _ready():
    _load_all_spells()

func _load_all_spells():
    # Load all .tres files from resources/spells/
    var spells = _get_spell_resources("res://resources/spells/")
    for spell_data in spells:
        spell_registry[spell_data.spell_name] = spell_data

func cast_spell(spell_name: String, caster: Node, direction: Vector2):
    if not spell_registry.has(spell_name):
        push_error("Unknown spell: " + spell_name)
        return
    
    var spell_data: SpellData = spell_registry[spell_name]
    
    # Route to appropriate behavior
    match spell_data.behavior_type:
        "projectile":
            _cast_projectile(spell_data, caster, direction)
        "instant":
            _cast_instant(spell_data, caster)
        "laser":
            _cast_laser(spell_data, caster, direction)
        "area":
            _cast_area(spell_data, caster)

func _cast_projectile(spell_data: SpellData, caster: Node, direction: Vector2):
    # Create projectile instance with behavior
    var projectile = ProjectileManager.spawn_projectile(
        spell_data.projectile_visual,
        caster.global_position,
        direction,
        spell_data
    )
    
    # Projectile handles its own trail and impact effects

func _cast_instant(spell_data: SpellData, caster: Node):
    # Execute instant effect behavior
    var behavior = spell_data.behavior_script.new()
    behavior.execute(spell_data, caster)
```

**Benefits:**
- SpellManager stays ~200 lines
- Add new spells by creating .tres files in editor
- No code changes needed for similar spells
- Easy to balance (edit resources, not code)
- Artists can create variants without programmer help

### Strategy 2: Spell Classes (For Unique Spells)

**When to use:** Complex, unique spells with special mechanics

```
scripts/spells/unique/
├── spell_base.gd           # Abstract base class
├── fireball_spell.gd       # Custom fireball logic
├── meteor_spell.gd         # Complex meteor shower
└── time_stop_spell.gd      # Game-altering spell
```

```gdscript
# spell_base.gd
class_name Spell extends Node

var spell_data: SpellData
var caster: Node

func initialize(data: SpellData, caster_node: Node):
    spell_data = data
    caster = caster_node

func cast(direction: Vector2):
    # Override in subclasses
    pass

func _create_cast_effect():
    if spell_data.cast_effect:
        var effect = spell_data.cast_effect.instantiate()
        effect.global_position = caster.global_position
        caster.get_parent().add_child(effect)
```

```gdscript
# meteor_spell.gd
class_name MeteorSpell extends Spell

func cast(direction: Vector2):
    _create_cast_effect()
    
    # Unique meteor logic
    for i in range(5):
        await get_tree().create_timer(0.3).timeout
        _spawn_meteor(caster.global_position + Vector2.UP * -200)

func _spawn_meteor(start_pos: Vector2):
    var meteor = spell_data.projectile_visual.instantiate()
    # ... custom meteor behavior
```

**Use for:**
- Spells with unique state machines
- Multi-phase spells (charge → release)
- Spells that interact with game systems in unique ways

**SpellManager routes to custom class:**
```gdscript
func cast_spell(spell_name: String, caster: Node, direction: Vector2):
    var spell_data: SpellData = spell_registry[spell_name]
    
    # Check if it has a custom spell class
    if spell_data.custom_spell_script:
        var spell_instance = spell_data.custom_spell_script.new()
        spell_instance.initialize(spell_data, caster)
        add_child(spell_instance)  # Add to tree temporarily
        spell_instance.cast(direction)
    else:
        # Use generic behavior system
        _cast_generic(spell_data, caster, direction)
```

### Strategy 3: Hybrid Approach (BEST FOR SCALING)

**Combine both:**
- 90% of spells use data-driven resources
- 10% unique spells use custom classes
- Shared behaviors for common patterns

```
resources/spells/
├── [100+ simple spell .tres files]

scripts/spells/
├── behaviors/              # Reusable (data-driven spells use these)
│   ├── projectile_behavior.gd
│   ├── homing_behavior.gd
│   └── aoe_behavior.gd
└── unique/                 # Custom (complex spells use these)
    ├── meteor_shower.gd
    ├── time_stop.gd
    └── black_hole.gd
```

## Effect Ownership in Detail

### 1. Cast Effects (Created by Caster)

**Responsibility:** Player/Enemy who casts

```gdscript
# player.gd
func _on_spell_cast_success(spell_name: String):
    is_casting = false
    
    # Player creates cast effect (common to all spells)
    _create_cast_effect()
    
    # SpellManager handles the actual spell behavior
    var direction = global_position.direction_to(get_global_mouse_position())
    SpellManager.cast_spell(spell_name, self, direction)

func _create_cast_effect():
    # Generic "I'm casting" effect
    var effect = generic_cast_effect.instantiate()
    effect.position = position
    get_parent().add_child(effect)
```

**Why:** Cast effect is about the caster, not the spell. Same visual for all spells (maybe).

**Alternative:** If each spell has unique cast animation, include in SpellData and SpellManager creates it.

### 2. Projectile Visuals (Created by Projectile)

**Responsibility:** The projectile instance itself

```gdscript
# projectile_base.gd
class_name Projectile extends Area2D

var spell_data: SpellData
var direction: Vector2
var visual_instance: Node2D
var trail_particles: CPUParticles2D

func initialize(data: SpellData, dir: Vector2, pos: Vector2):
    spell_data = data
    direction = dir
    global_position = pos
    
    # Projectile creates its own visual
    _setup_visual()
    _setup_trail()

func _setup_visual():
    if spell_data.projectile_visual:
        visual_instance = spell_data.projectile_visual.instantiate()
        add_child(visual_instance)

func _setup_trail():
    # Trail is intrinsic to projectile movement
    trail_particles = CPUParticles2D.new()
    trail_particles.emitting = true
    # ... configure trail ...
    add_child(trail_particles)

func _on_collision(target: Node):
    _create_impact_effect()
    _deal_damage(target)
    queue_free()

func _create_impact_effect():
    # Projectile creates its own impact effect
    if spell_data.impact_effect:
        var effect = spell_data.impact_effect.instantiate()
        effect.global_position = global_position
        get_tree().root.add_child(effect)  # Add to root so it persists
```

**Why:** Projectile knows when/where it hits. Encapsulation - projectile is self-contained.

### 3. Hit Reaction (Created by Target)

**Responsibility:** The enemy/player being hit

```gdscript
# enemy.gd
func take_damage(amount: int):
    health -= amount
    
    # Enemy creates its own damage reaction
    _show_damage_flash()
    _spawn_damage_number(amount)
    
    if health <= 0:
        die()

func _show_damage_flash():
    # Flash sprite white briefly
    modulate = Color(1, 1, 1, 1)
    await get_tree().create_timer(0.1).timeout
    modulate = Color(1, 1, 1, 1)

func _spawn_damage_number(amount: int):
    var damage_text = damage_number_scene.instantiate()
    damage_text.text = str(amount)
    damage_text.global_position = global_position + Vector2.UP * 20
    get_parent().add_child(damage_text)

func die():
    # Enemy creates its own death effect
    var death_effect = death_effect_scene.instantiate()
    death_effect.global_position = global_position
    get_parent().add_child(death_effect)
    
    queue_free()
```

**Why:** Enemy owns its death visuals. Different enemies = different death effects.

### 4. Area/Persistent Effects (Created by SpellManager)

**Responsibility:** SpellManager (or dedicated EffectManager)

```gdscript
# spell_manager.gd
func _cast_area(spell_data: SpellData, caster: Node):
    # Create a persistent area effect in the world
    var area_effect = spell_data.area_effect_scene.instantiate()
    area_effect.initialize(spell_data, caster)
    
    # Add to world, not to any particular entity
    var world = get_tree().current_scene
    world.add_child(area_effect)
```

```gdscript
# burning_ground_effect.gd
extends Node2D

var damage_per_second: int
var duration: float

func initialize(spell_data: SpellData, caster: Node):
    damage_per_second = spell_data.damage
    duration = spell_data.duration
    
    _setup_visuals()
    _setup_hitbox()
    
    await get_tree().create_timer(duration).timeout
    queue_free()

func _setup_visuals():
    # Effect manages its own particles/animation
    $Particles.emitting = true
    $AnimatedSprite.play("burn")
```

**Why:** These effects aren't owned by any entity. They're world objects.

## File Organization for 100+ Spells

### Recommended Structure

```
project/
├── scripts/
│   ├── singletons/
│   │   ├── spell_manager.gd         # ~200 lines, routing only
│   │   └── projectile_manager.gd    # Pooling and spawning
│   └── spells/
│       ├── spell_data.gd            # Resource class definition
│       ├── spell_registry.gd        # Optional: Database helper
│       ├── behaviors/               # Reusable behavior components
│       │   ├── behavior_base.gd
│       │   ├── projectile_behavior.gd
│       │   ├── homing_behavior.gd
│       │   ├── aoe_behavior.gd
│       │   └── chain_behavior.gd
│       ├── projectiles/             # Projectile logic
│       │   ├── projectile_base.gd
│       │   ├── projectile_linear.gd
│       │   ├── projectile_homing.gd
│       │   └── projectile_arc.gd
│       └── unique/                  # Custom spell classes (10% of spells)
│           ├── meteor_shower.gd
│           ├── black_hole.gd
│           └── time_stop.gd
│
├── resources/
│   └── spells/                      # Data files (90% of spells)
│       ├── fire/
│       │   ├── fireball.tres        # 20 fire spell variants
│       │   ├── flame_wave.tres
│       │   └── ...
│       ├── ice/
│       │   ├── ice_shard.tres       # 15 ice spell variants
│       │   └── ...
│       ├── lightning/
│       │   └── ...
│       ├── earth/
│       │   └── ...
│       └── arcane/
│           └── ...
│
└── scenes/
    ├── spell_visuals/               # Visual-only scenes (NO LOGIC)
    │   ├── projectiles/
    │   │   ├── fireball_visual.tscn      # Just sprite + particles
    │   │   ├── ice_shard_visual.tscn
    │   │   └── ...
    │   ├── impacts/
    │   │   ├── fire_explosion.tscn
    │   │   ├── ice_shatter.tscn
    │   │   └── ...
    │   ├── cast_effects/
    │   │   ├── fire_cast.tscn
    │   │   └── ice_cast.tscn
    │   └── area_effects/
    │       ├── burning_ground.tscn
    │       └── ice_field.tscn
    └── effects/
        └── [existing generic effects]
```

### Naming Conventions

**Resources (data files):**
- `fireball.tres`, `ice_bolt.tres` (spell configs)
- Organized by element/school

**Visual Scenes (no logic):**
- `[name]_visual.tscn` for projectiles
- `[name]_impact.tscn` for impacts
- `[name]_cast.tscn` for cast effects

**Scripts (logic):**
- `[name]_behavior.gd` for reusable behaviors
- `[name]_spell.gd` for unique spell classes

## Example: Creating a New Spell

### Scenario: Add "Ice Lance" spell

**Step 1:** Check if similar spell exists
- "Fireball" exists and is a linear projectile
- Ice Lance is also a linear projectile
- Can reuse `projectile_behavior.gd`

**Step 2:** Create visual scenes (artist work)
```
scenes/spell_visuals/projectiles/ice_lance_visual.tscn
  ├── Sprite2D (ice lance texture)
  └── CPUParticles2D (frost trail)

scenes/spell_visuals/impacts/ice_lance_impact.tscn
  ├── CPUParticles2D (ice shatter)
  └── AnimatedSprite2D (shatter animation)
```

**Step 3:** Create spell resource (in Godot editor)
```
resources/spells/ice/ice_lance.tres
  - Spell Name: "GLACIES HASTA"
  - Description: "Pierce enemies with frozen spear"
  - Behavior Type: "projectile"
  - Behavior Script: projectile_behavior.gd
  - Projectile Visual: ice_lance_visual.tscn
  - Impact Effect: ice_lance_impact.tscn
  - Damage: 20
  - Speed: 600
  - Pierce Count: 2
  - Lifetime: 4.0
```

**Step 4:** That's it!
- No code changes needed
- SpellManager auto-loads from resources/spells/
- Spell works immediately

**If you need unique behavior:**
- Create `scripts/spells/unique/ice_lance_spell.gd`
- Set `custom_spell_script` in the resource
- Implement unique logic

## Code Size Comparison

### BAD: Monolithic SpellManager
```gdscript
# spell_manager.gd (5000+ lines)
var spells = {
    "FIREBALL": {...},
    "FIREBALL_LARGE": {...},
    "FIREBALL_SMALL": {...},
    # ... 97 more spells ...
}

var fireball_visual = preload(...)
var fireball_large_visual = preload(...)
# ... 97 more preloads ...

func cast_spell(spell_name: String):
    match spell_name:
        "FIREBALL":
            _cast_fireball()
        "FIREBALL_LARGE":
            _cast_fireball_large()
        # ... 97 more cases ...

func _cast_fireball():
    # 50 lines of fireball logic
    ...

func _cast_fireball_large():
    # 50 lines of large fireball logic
    ...

# ... 97 more functions ...
```

### GOOD: Data-Driven System
```gdscript
# spell_manager.gd (~200 lines total)
var spell_registry: Dictionary = {}

func _ready():
    _load_all_spells()

func cast_spell(spell_name: String, caster: Node, direction: Vector2):
    var spell_data = spell_registry.get(spell_name)
    if not spell_data:
        return
    
    # Route to behavior
    match spell_data.behavior_type:
        "projectile":
            _cast_projectile(spell_data, caster, direction)
        "instant":
            _cast_instant(spell_data, caster)
        "laser":
            _cast_laser(spell_data, caster, direction)
```

```
100 spell .tres files @ ~100 bytes each = 10KB of data
vs
5000 lines of code @ ~50 bytes/line = 250KB of code
```

## Summary of Responsibilities

| Component | Responsibility | Creates |
|-----------|---------------|---------|
| **SpellManager** | Routing, validation, orchestration | Nothing (just routes) |
| **ProjectileManager** | Spawning, pooling projectiles | Projectile instances |
| **Projectile Instance** | Movement, collision, self-contained | Trail effects, impact effects |
| **Caster (Player/Enemy)** | Initiating cast, animation | Cast effects (optional) |
| **Target (Enemy/Player)** | Taking damage, reacting | Hit reactions, death effects |
| **Area Effect** | Persistent world effect | Own particles/animations |
| **Behavior Scripts** | Reusable logic patterns | Nothing (pure logic) |
| **Spell Resources** | Data/configuration | Nothing (just data) |

## Key Takeaways

1. **SpellManager is a router, not a god object**
   - It validates and routes, doesn't implement
   
2. **Objects manage their own visuals**
   - Projectiles create their trail and impact
   - Enemies create their death effects
   
3. **Data-driven scales better than code-driven**
   - 100 spells = 100 small files, not 1 huge file
   
4. **Separation of concerns**
   - Logic in scripts
   - Data in resources
   - Visuals in scenes (no logic)
   
5. **Hybrid approach for flexibility**
   - Generic spells = data
   - Unique spells = custom classes

