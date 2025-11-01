# Performance Testing Experiments

Collection of performance testing scenes to benchmark various aspects of Godot's engine.

## Available Tests

### 1. Moving Objects Test (`performance_test.tscn`)
**Purpose**: Test raw rendering and update performance with many simple moving objects.

**Features**:
- Spawns thousands of colored circles that bounce around the screen
- Each object has simple physics (velocity + bounds checking)
- Shows FPS, object count, memory usage, and process times

**Controls**:
- Q: Add 100 objects
- W: Add 1,000 objects
- E: Add 10,000 objects
- A: Remove 100 objects
- S: Remove 1,000 objects
- D: Remove 10,000 objects
- SPACE: Toggle movement
- R: Reset to 1,000 objects

**What it tests**: Node updates, _process() calls, simple rendering, memory allocation

**Expected Results**: 
- Modern systems should handle 5,000-10,000+ objects at 60fps
- Performance degradation indicates CPU bottleneck in process loop

---

### 2. Physics Performance Test (`physics_performance_test.tscn`)
**Purpose**: Test physics engine performance with colliding RigidBody2D objects.

**Features**:
- Spawns RigidBody2D objects with CircleShape2D colliders
- All objects collide with each other
- Shows active physics bodies count
- More demanding than simple movement test

**Controls**:
- Q: Add 50 objects
- W: Add 200 objects
- E: Add 1,000 objects
- A: Remove 50 objects
- S: Remove 200 objects
- D: Remove 1,000 objects
- SPACE: Add random impulse to all objects
- R: Reset to 200 objects

**What it tests**: Physics calculations, collision detection, RigidBody2D performance

**Expected Results**:
- 200-500 objects: Good performance
- 500-1,000 objects: Moderate slowdown
- 1,000+ objects: Significant FPS drop
- Physics is MUCH more expensive than simple movement

---

### 3. Calculation Performance Test (`calculation_performance_test.tscn`)
**Purpose**: Test raw computational performance with different operation types.

**Features**:
- Four test modes: Math, Array, Dictionary, String operations
- Adjustable calculations per frame
- Shows exact time spent on calculations

**Test Types**:
1. **Math Ops**: sin, cos, sqrt, pow operations
2. **Array Ops**: Array access, modification, sorting
3. **Dictionary Ops**: Key lookups, updates, key retrieval
4. **String Ops**: Concatenation, splitting, length checks

**Controls**:
- 1: Math operations mode
- 2: Array operations mode
- 3: Dictionary operations mode
- 4: String operations mode
- Q: Double calculations per frame
- A: Half calculations per frame
- W: 10x calculations per frame
- S: 1/10th calculations per frame

**What it tests**: Pure computational performance, data structure efficiency

**Expected Results**:
- Math: 100K-1M+ ops/frame possible
- Array: 10K-100K ops/frame
- Dictionary: 10K-100K ops/frame
- String: 1K-10K ops/frame (strings are expensive!)

---

## Suggested Additional Performance Tests

### 4. Particle System Test
**What to test**:
- Multiple GPUParticles2D vs CPUParticles2D
- Particle count impact on FPS
- Emitter count vs particle count per emitter

**Implementation ideas**:
- Spawn many particle emitters
- Toggle between GPU and CPU particles
- Adjust particle lifetime and count

### 5. Draw Calls / Rendering Test
**What to test**:
- Sprite batching efficiency
- Draw call overhead
- Texture swapping impact

**Implementation ideas**:
- Many sprites with same texture (good batching)
- Many sprites with different textures (poor batching)
- Many draw_* calls in _draw()
- Shader complexity impact

### 6. Pathfinding / Navigation Test
**What to test**:
- NavigationAgent2D performance with many agents
- A* pathfinding calculations
- Path recalculation frequency

**Implementation ideas**:
- Spawn many NavigationAgent2D nodes
- Complex navigation mesh
- Agents constantly recalculating paths
- Moving obstacles

### 7. Tilemap / Large World Test
**What to test**:
- TileMap rendering performance
- Large world streaming
- Culling efficiency

**Implementation ideas**:
- Generate huge TileMap
- Camera movement across large area
- Different tile counts
- Autotile vs individual tiles

### 8. Signal / Method Call Test
**What to test**:
- Signal emission overhead
- Method call performance
- Call deferred vs direct call

**Implementation ideas**:
- Many nodes emitting signals each frame
- Deep call chains
- Recursive method calls

### 9. Animation / Tween Test
**What to test**:
- AnimationPlayer performance
- Tween performance
- Interpolation overhead

**Implementation ideas**:
- Many AnimationPlayers running simultaneously
- Many active Tweens
- Complex animation curves

### 10. Shader / Visual Effects Test
**What to test**:
- Shader complexity impact
- Post-processing effects
- Screen-space shaders

**Implementation ideas**:
- Toggle expensive shader effects
- Multiple shader passes
- Full-screen effects vs per-object

### 11. Audio Performance Test
**What to test**:
- AudioStreamPlayer count
- Audio bus effects
- 3D audio spatialization

**Implementation ideas**:
- Spawn many AudioStreamPlayers
- Add effects to audio bus
- Many AudioStreamPlayer3D nodes

### 12. Scene Instancing Test
**What to test**:
- Scene loading time
- Instantiation overhead
- add_child() performance

**Implementation ideas**:
- Rapidly instantiate complex scenes
- Measure time to load and add to tree
- Compare simple vs complex scene structures

---

## Performance Monitoring Utilities

**Godot provides these useful monitors**:
```gdscript
Performance.TIME_FPS
Performance.TIME_PROCESS
Performance.TIME_PHYSICS_PROCESS
Performance.MEMORY_STATIC
Performance.MEMORY_DYNAMIC
Performance.OBJECT_COUNT
Performance.OBJECT_RESOURCE_COUNT
Performance.OBJECT_NODE_COUNT
Performance.RENDER_TOTAL_OBJECTS_IN_FRAME
Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME
Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME
Performance.PHYSICS_2D_ACTIVE_OBJECTS
Performance.PHYSICS_2D_COLLISION_PAIRS
```

**System monitoring**:
```gdscript
Engine.get_frames_per_second()
OS.get_static_memory_usage()
Time.get_ticks_msec()
Time.get_ticks_usec()
```

---

## Tips for Performance Testing

1. **Run in Release mode** - Debug builds are slower
2. **Profile before optimizing** - Don't guess bottlenecks
3. **Test on target hardware** - Desktop ≠ Mobile ≠ Web
4. **Isolate tests** - Test one thing at a time
5. **Use the Profiler** - Godot's built-in profiler is powerful
6. **Compare alternatives** - Test different approaches

## Common Bottlenecks in Godot

1. **Too many _process() calls** - Minimize active nodes
2. **Physics overload** - Too many collision checks
3. **Unoptimized draw calls** - Break batching with texture/shader swaps
4. **String operations** - Very expensive, cache when possible
5. **Unculled rendering** - Draw offscreen objects
6. **Memory allocations** - Creating/destroying objects each frame

