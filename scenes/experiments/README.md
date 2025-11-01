# Charge Ability Experiments

This directory contains experiments exploring different charge-based abilities with various targeting and feedback mechanisms.

---

# Fireball Charge Experiment

## Purpose
Test charging mechanics and micro feedback systems. This experiment explores:
- Hold-to-charge input pattern
- Visual feedback during charge buildup
- Power scaling with charge duration
- Micro feedback to communicate state changes

## How to Run
1. Open `fireball_charge_experiment.tscn` in Godot
2. Press F6 (or click Play Scene)
3. Click and hold left mouse button to charge
4. Release to launch fireball

## Controls
- **Left Mouse Button (Hold)**: Charge fireball
- **Left Mouse Button (Release)**: Launch fireball

## Mechanics
- **Charge Duration**: 0-3 seconds maximum
- **Power Scaling**: 1x to 3x damage
- **Speed Scaling**: 300 to 800 pixels/second
- **Visual Scaling**: 0.5x to 1.5x size

## Current Feedback Systems

### Visual
1. **Growing Charge Indicator**: Scales from 0.3x to 2.5x
2. **Color Progression**: Orange → Red → Bright Yellow-White
3. **Alpha Fade-In**: 50% to 100% opacity
4. **Pulse Effect**: Activates at 70% charge
5. **Screen Flash**: Triggers at 95% charge
6. **Launch Particles**: Explosion effect on release
7. **Trail Particles**: Following the fireball
8. **Impact Particles**: On collision

### UI
1. **Charge Percentage**: Real-time display
2. **Hold Duration**: Time counter
3. **Power Multiplier**: Shows damage scaling

## Testing Questions
- Does 3 seconds feel like the right max charge time?
- Is the visual progression clear and satisfying?
- Does the screen flash feel good or annoying?
- Do players naturally wait for max charge?
- What charge percentage do players release at most often?
- Does the pulsing at 70% communicate "getting close to max"?

## Next Steps
See `FEEDBACK_IDEAS.md` for 35+ additional micro feedback proposals including:
- Audio feedback (charge loop, impact sounds)
- Advanced particles (swirling rings, heat distortion)
- Screen effects (shake, slow-motion, vignette)
- Haptic feedback
- Time manipulation
- Combo systems

## Related Experiments
This experiment addresses questions from `gameplay_tension_experiments.md`:
- **Q1**: Input complexity (hold + timing)
- **Q2**: Input buffers (charge duration tolerance)
- **Q7**: Execution + timer pressure (3s window)
- **Q13**: Forgiveness (partial charge still launches)

---

# Lightning Charge Experiment

## Purpose
Test raycast-based instant strike mechanics with precision targeting. This experiment explores:
- Hold-to-charge with raycast targeting
- Cursor-based precise targeting system
- Instant hit mechanics (vs projectile)
- Target highlighting and feedback
- Risk/reward of precision aiming

## How to Run
1. Open `lightning_charge/lightning_charge_experiment.tscn` in Godot
2. Press F6 (or click Play Scene)
3. Aim with mouse, hold to charge
4. Release to strike instantly

## Controls
- **Mouse Movement**: Aim/target
- **Left Mouse Button (Hold)**: Charge lightning
- **Left Mouse Button (Release)**: Strike instantly along raycast

## Mechanics
- **Charge Duration**: 0-3 seconds maximum
- **Damage Scaling**: 30 to 150 damage
- **Range**: 1500 pixels
- **Hit Detection**: Raycast (instant, no travel time)
- **Targeting**: Shows reticle and highlights target under cursor

## Key Differences from Fireball
1. **Targeting Mechanism**: 
   - Fireball: Directional aiming (where you release)
   - Lightning: Precise cursor targeting (what's under cursor)
   
2. **Hit Detection**:
   - Fireball: Projectile with travel time
   - Lightning: Instant raycast hit
   
3. **Feedback**:
   - Fireball: Launch particles and trail
   - Lightning: Target line preview, hit confirmation flash
   
4. **Skill Expression**:
   - Fireball: Predicting movement, leading targets
   - Lightning: Precise cursor placement, timing release

## Current Feedback Systems

### Visual
1. **Charge Indicator**: Blue/cyan energy ball at origin
2. **Target Line**: Shows where lightning will strike
3. **Targeting Reticle**: Crosshair at cursor position
4. **Target Highlighting**: Enemies turn white when targeted
5. **Lightning Bolt**: Jagged animated line with flicker effect
6. **Impact Flash**: Bright flash at strike point
7. **Impact Particles**: Electric sparks at hit location
8. **Screen Flash**: At 95% charge

### UI
1. **Charge Percentage**: Real-time display
2. **Hold Duration**: Time counter
3. **Damage Value**: Shows scaled damage
4. **Target Name**: Displays what you're aiming at

## Testing Questions
- Does the precision targeting feel good?
- Is the instant hit satisfying compared to projectile?
- Does target highlighting help or hurt the experience?
- Is it clear where the lightning will strike?
- Do players prefer directional (fireball) or precision (lightning) targeting?
- Does the 3-second charge window work for a precision mechanic?

## Design Notes
Lightning uses a different targeting model than fireball because:
- Instant hits require precise aiming (cursor position)
- Raycast semantics match "lightning bolt" fantasy
- Target highlighting reduces frustration with precision mechanics
- Preview line helps communicate exactly what will be hit

