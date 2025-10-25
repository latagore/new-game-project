# Projectile and Laser System Architecture

## Overview

This document outlines the architecture for a comprehensive projectile and hitscan laser system that integrates with the existing spell casting framework. The system is designed to be extensible, performant, and easy to configure for different spell types.

## Design Goals

1. **Integration:** Seamlessly work with existing `SpellManager` singleton
2. **Flexibility:** Support multiple projectile types and behaviors
3. **Performance:** Handle multiple projectiles without significant framerate impact
4. **Extensibility:** Easy to add new projectile types and behaviors
5. **Visual Appeal:** Support various rendering techniques for different spell effects

## Architecture Overview

### Core Components

```
scripts/projectiles/
├── projectile_base.gd          # Base class for all projectiles
├── projectile_manager.gd       # Singleton to manage active projectiles
├── projectile_linear.gd        # Standard linear projectile
├── projectile_homing.gd        # Homing projectile (future)
├── projectile_arc.gd           # Arcing projectile (future)
└── laser_hitscan.gd            # Hitscan laser implementation

scenes/projectiles/
├── projectile_fireball.tscn    # Example: Fire projectile
├── projectile_ice_shard.tscn   # Example: Ice projectile
└── laser_beam.tscn             # Laser beam visual
```

## 1. Projectile System

### 1.1 Base Projectile Class

**Purpose:** Abstract base class that all projectiles inherit from

**Key Properties:**
- `speed: float` - Movement speed
- `damage: int` - Damage dealt on impact
- `lifetime: float` - Time before auto-destruction
- `pierce_count: int` - Number of enemies it can pierce through (0 = destroy on hit)
- `owner_entity: Node` - Who spawned it (for friendly fire prevention)

**Key Methods:**
- `initialize(direction: Vector2, position: Vector2, properties: Dictionary)`
- `_physics_process(delta)` - Update position and check lifetime
- `_on_hit(target: Node)` - Called when hitting a valid target
- `_on_lifetime_expired()` - Called when lifetime runs out
- `destroy()` - Clean up and remove projectile

**Collision Handling:**
- Projectiles use `Area2D` nodes
- Collision layer: 8 (new layer for projectiles)
- Collision mask: 4 (detects hurtboxes)
- On `area_entered` signal, check if target is in correct group and deal damage

### 1.2 Linear Projectile

**Extends:** `projectile_base.gd`

**Behavior:**
- Moves in a straight line at constant speed
- Direction set on initialization
- Simple and performant

**Implementation:**
```gdscript
func _physics_process(delta):
    position += direction * speed * delta
    
    # Update lifetime
    current_lifetime += delta
    if current_lifetime >= lifetime:
        _on_lifetime_expired()
```

### 1.3 Future Projectile Types (Extensibility)

**Homing Projectile:**
- Seeks nearest enemy within detection radius
- Smooth turning with max turn rate
- Falls back to linear if no target

**Arc Projectile:**
- Follows parabolic trajectory
- Uses gravity simulation
- Good for lobbed spells

**Bouncing Projectile:**
- Reflects off walls
- Limited bounce count
- Maintains or loses energy per bounce

## 2. Laser/Hitscan System

### 2.1 Hitscan Laser

**Purpose:** Instant-hit laser beams that don't travel over time

**Implementation Approach:**
- Use raycasting for hit detection
- `Line2D` or custom shader for visual beam
- Beam exists for brief duration (visual effect)

**Key Properties:**
- `max_range: float` - Maximum laser distance
- `damage: int` - Damage dealt
- `beam_width: float` - Visual width (doesn't affect hitbox)
- `beam_duration: float` - How long beam visual persists
- `pierce: bool` - Whether it hits multiple enemies

**Hit Detection Algorithm:**
```gdscript
func cast_laser(origin: Vector2, direction: Vector2):
    var space_state = get_world_2d().direct_space_state
    var query = PhysicsRayQueryParameters2D.create(
        origin, 
        origin + direction * max_range
    )
    query.collision_mask = 4  # Hurtbox layer
    
    if pierce:
        # Use intersect_ray multiple times, excluding previous hits
        var hits = []
        var current_origin = origin
        while true:
            var result = space_state.intersect_ray(query)
            if result.is_empty():
                break
            hits.append(result)
            # Update query to start past this hit
            query.from = result.position + direction * 0.1
    else:
        # Single target
        var result = space_state.intersect_ray(query)
        if not result.is_empty():
            _deal_damage(result.collider)
```

### 2.2 Continuous Beam Laser

**Purpose:** Laser that persists for duration (like a flamethrower)

**Implementation:**
- Similar to hitscan but updates every frame
- Uses `Area2D` with elongated collision shape
- Shape updates to match current target/range
- Can use `RayCast2D` node for collision

**Considerations:**
- More expensive than instant hitscan
- Better for "channeled" spells
- Provides continuous damage ticks

## 3. Projectile Manager

### 3.1 Singleton Design

**Purpose:** Central management of all active projectiles

**Responsibilities:**
- Pool management for performance
- Spawn/despawn projectiles
- Track active projectiles
- Global projectile limits (if needed)

**Key Methods:**
```gdscript
func spawn_projectile(
    projectile_scene: PackedScene,
    position: Vector2,
    direction: Vector2,
    properties: Dictionary
) -> Node:
    var projectile = _get_from_pool(projectile_scene)
    if projectile == null:
        projectile = projectile_scene.instantiate()
    
    projectile.initialize(direction, position, properties)
    add_child(projectile)
    active_projectiles.append(projectile)
    return projectile

func return_to_pool(projectile: Node):
    active_projectiles.erase(projectile)
    projectile.reset()
    projectile.visible = false
    # Store in pool dictionary by scene path
```

### 3.2 Object Pooling

**Why:** Reduce instantiation overhead

**Strategy:**
- Pool by projectile type (scene path)
- Max pool size per type (e.g., 20)
- Clear pools on scene change

## 4. Integration with Spell System

### 4.1 Spell Manager Updates

Add new spell effect types to `spell_manager.gd`:

```gdscript
var spells = {
    "IGNIS SAGITTA": {
        "description": "Fires a bolt of flame",
        "effect": "projectile",
        "projectile_scene": preload("res://scenes/projectiles/projectile_fireball.tscn"),
        "properties": {
            "speed": 400,
            "damage": 15,
            "lifetime": 3.0,
            "pierce_count": 0
        }
    },
    "GLACIES HASTA": {
        "description": "Launches ice shards",
        "effect": "projectile_multi",
        "projectile_scene": preload("res://scenes/projectiles/projectile_ice_shard.tscn"),
        "count": 3,
        "spread_angle": 30,
        "properties": {
            "speed": 500,
            "damage": 10,
            "lifetime": 2.5
        }
    },
    "FULMEN RADIUS": {
        "description": "Instant lightning beam",
        "effect": "laser",
        "laser_scene": preload("res://scenes/projectiles/laser_beam.tscn"),
        "properties": {
            "max_range": 600,
            "damage": 25,
            "pierce": true,
            "beam_duration": 0.3
        }
    }
}

func cast_spell(spell_name: String):
    # ... existing code ...
    
    match effect:
        "projectile":
            _cast_projectile_spell(spell_data)
        "projectile_multi":
            _cast_multi_projectile_spell(spell_data)
        "laser":
            _cast_laser_spell(spell_data)
        # ... existing cases ...

func _cast_projectile_spell(spell_data: Dictionary):
    var player = get_tree().get_first_node_in_group("player")
    if player == null:
        return
    
    # Get direction player is facing or mouse direction
    var direction = _get_cast_direction(player)
    
    ProjectileManager.spawn_projectile(
        spell_data.projectile_scene,
        player.global_position,
        direction,
        spell_data.properties
    )
```

### 4.2 Cast Direction

**Options for determining projectile direction:**

1. **Mouse Position:** Most intuitive for top-down
   ```gdscript
   var direction = (get_global_mouse_position() - player.global_position).normalized()
   ```

2. **Last Movement Direction:** Good for gamepad
   ```gdscript
   var direction = player.last_movement_direction
   ```

3. **Fixed Direction:** Face direction player sprite is facing

**Recommendation:** Use mouse position for primary control, fall back to last movement direction if no mouse movement detected

## 5. Rendering Considerations

### 5.1 Projectile Visuals

**Sprite-Based:**
- Simple 2D sprite (e.g., fireball texture)
- AnimatedSprite2D for animated projectiles
- Rotate sprite to face direction of travel
- Add rotation for spinning projectiles

**Particle-Based:**
- `CPUParticles2D` or `GPUParticles2D` as child
- Trail effect behind projectile
- Emit particles continuously during flight
- Explosion particles on impact

**Combined Approach:**
- Core sprite with particle trail
- Example: Fireball = glowing sphere sprite + flame trail particles

### 5.2 Laser Visuals

**Line2D Method:**
```gdscript
var line = Line2D.new()
line.width = beam_width
line.default_color = Color(0.3, 0.7, 1.0, 0.8)
line.add_point(start_position)
line.add_point(end_position)

# Optional: Animated width pulse
line.width_curve = create_pulse_curve()
```

**Custom Shader Method:**
- Better visual quality
- Can add glow, distortion, energy effects
- UV scrolling for "flowing" energy
- Example shader features:
  - Fresnel glow on edges
  - Noise-based distortion
  - Pulsing intensity
  - Color gradient along beam

**Sprite/TextureRect Method:**
- Use elongated sprite (e.g., 1024x32 laser texture)
- Scale and rotate to match hit point
- Good for stylized lasers
- Simple but less flexible

### 5.3 Performance Considerations

**Projectiles:**
- Limit maximum active projectiles (e.g., 50 total)
- Use `VisibleOnScreenNotifier2D` to cull off-screen projectiles
- Prefer `CPUParticles2D` for mobile, `GPUParticles2D` for desktop
- Pool projectile instances

**Lasers:**
- Short-lived, typically not a performance issue
- If continuous beam: limit update rate (e.g., every 2-3 frames)
- Use simpler shaders on lower-end devices

**Impact Effects:**
- Reuse particle effects from object pool
- One-shot particle systems that auto-free
- Avoid creating new nodes every frame

### 5.4 Visual Polish Ideas

**Projectile Trails:**
- Fading trail of previous positions
- Use `Line2D` with gradient alpha
- Or particle system with short lifetime

**Screen Shake:**
- On powerful projectile cast or impact
- Camera shake proportional to spell power

**Flash Effects:**
- Brief white/colored flash on impact
- Use `CanvasModulate` or sprite modulate

**Lighting:**
- `PointLight2D` attached to projectile
- Especially effective for fire/lightning spells
- Animate intensity for pulsing effect

**Area Indicators:**
- For AoE projectiles, show impact radius
- Decal or sprite at predicted landing point
- Helps player aim

## 6. Configuration System

### 6.1 Projectile Resource

Create custom resource for easy projectile configuration:

```gdscript
# projectile_data.gd
class_name ProjectileData
extends Resource

@export var speed: float = 300.0
@export var damage: int = 10
@export var lifetime: float = 3.0
@export var pierce_count: int = 0
@export var homing: bool = false
@export var homing_strength: float = 0.0
@export var visual_scene: PackedScene
@export var impact_effect: PackedScene
@export var trail_color: Color = Color.WHITE
@export var collision_radius: float = 8.0
```

**Benefits:**
- Configure in Godot editor
- Share configs between similar spells
- Easy to balance and tweak
- Type-safe

### 6.2 Spell Resource

Similarly, create spell resource:

```gdscript
# spell_data.gd
class_name SpellData
extends Resource

@export var spell_name: String
@export var transcription: String
@export var description: String
@export_enum("instant", "projectile", "laser", "area") var type: String
@export var projectile_data: ProjectileData
@export var cooldown: float = 0.0
@export var mana_cost: int = 0  # For future mana system
```

## 7. Testing & Debugging

### 7.1 Debug Visualization

**Projectile Path:**
- Draw trajectory prediction
- Show collision radius
- Display lifetime remaining

**Laser Raycast:**
- Visualize ray with `Line2D`
- Show all pierce targets
- Display max range circle

**Debug Menu:**
- Toggle collision shape visibility
- Slow motion mode
- Spawn test projectiles
- Display active projectile count

### 7.2 Testing Scenarios

1. **Single Target:** One enemy, various ranges
2. **Multiple Targets:** Test pierce mechanics
3. **Obstructions:** Test collision with walls (if applicable)
4. **Edge Cases:** Spawn at edge of map, target off-screen
5. **Performance:** Spawn 50+ projectiles, measure FPS
6. **Rapid Fire:** Cast multiple spells quickly, check for issues

## 8. Implementation Roadmap

### Phase 1: Basic Projectile (MVP)
1. Create `projectile_base.gd` and `projectile_linear.gd`
2. Create simple projectile scene (sprite + Area2D)
3. Implement basic collision with hurtboxes
4. Add one test projectile spell to spell manager
5. Test with player casting at enemies

### Phase 2: Projectile Manager
1. Create `projectile_manager.gd` singleton
2. Implement basic spawning through manager
3. Add object pooling
4. Update spell manager to use ProjectileManager

### Phase 3: Enhanced Visuals
1. Add particle trails to projectiles
2. Create impact effects
3. Implement multiple projectile types (fire, ice, lightning)
4. Polish timing and feel

### Phase 4: Hitscan Laser
1. Create `laser_hitscan.gd`
2. Implement raycasting collision
3. Create laser beam visual (Line2D or shader)
4. Add laser spell to spell manager
5. Test pierce and non-pierce modes

### Phase 5: Advanced Features
1. Implement homing projectiles
2. Add area-of-effect explosions
3. Create continuous beam lasers
4. Implement projectile-projectile interactions (future)

### Phase 6: Polish & Optimization
1. Performance profiling
2. Add screen shake and camera effects
3. Sound effects integration (when audio system exists)
4. Balance damage and speeds
5. Create configuration resources

## 9. Future Enhancements

### Potential Advanced Features
- **Projectile Combinations:** Spells that modify other projectiles mid-flight
- **Elemental Interactions:** Fire melts ice, water conducts lightning, etc.
- **Ricochet/Bounce:** Projectiles reflect off walls
- **Splitting Projectiles:** One projectile becomes multiple
- **Gravity Wells:** Projectiles that bend paths of other projectiles
- **Shields/Barriers:** Projectiles that block enemy projectiles
- **Delayed Detonation:** Time-bomb projectiles
- **Chain Lightning:** Laser that jumps between enemies
- **Seeking Clusters:** Swarm of mini-projectiles

### Technical Improvements
- **Projectile Prediction:** Show where projectile will hit
- **Save/Load System:** Serialize active projectiles
- **Multiplayer Support:** Synchronize projectiles across network
- **Replay System:** Record and replay projectile movements
- **Procedural Spells:** Generate random projectile properties

## 10. Collision Layer Reference

Current layer usage:
- Layer 1: (Unknown/default)
- Layer 2: Hitboxes (player attacks)
- Layer 4: Hurtboxes (enemy/player vulnerable areas)
- **Layer 8: Projectiles** (proposed)

Collision matrix:
- Projectiles (Layer 8) detect Hurtboxes (Layer 4)
- Projectiles can optionally detect walls/obstacles (future)
- Player projectiles don't hit player hurtbox (filter by group or owner)

## Conclusion

This architecture provides a solid foundation for a flexible, performant projectile and laser system. It integrates cleanly with the existing spell casting mechanics while remaining extensible for future spell types and behaviors. The modular design allows for incremental implementation, starting with basic linear projectiles and building up to advanced homing missiles and continuous beam lasers.

The visual rendering options provide multiple paths depending on desired aesthetic and performance requirements, from simple sprite-based projectiles to complex shader-driven laser beams with particle effects.

