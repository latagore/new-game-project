# Animation Principles Applied to Fireball Experiment

This document explains how the 12 principles of animation (from Disney) have been applied to the fireball charge experiment for better game feel.

---

## 1. Squash & Stretch
**Purpose**: Shows weight, force, and energy in objects

### Charge Indicator
- **Early charge (0-30%)**: Vertical stretch during buildup
  - Narrower horizontally, taller vertically
  - Communicates "gathering energy upward"
  
### Launch Anticipation
- **Before launch**: Squashes to 70% scale, extra squash horizontally (60%)
  - Creates wind-up feeling
  - Makes the release more impactful by contrast

### Target on Hit
- **Impact reaction**: Squashes horizontally based on damage strength
  - Light hit: 20% squash
  - Heavy hit: 30% squash
  - Bounces back with elastic easing

### Fireball Impact
- **Before explosion**: Briefly expands to 1.4x scale
- **Explosion**: Expands to 2x while fading
- Communicates energy transfer

---

## 2. Anticipation
**Purpose**: Prepares the audience for an action

### Starting Charge
- Charge indicator pops in from **zero scale**
- Uses `TRANS_BACK` for overshoot
- Duration: 0.15s
- Signals: "Something is beginning"

### Launch Anticipation
- 0.08s squash phase before fireball spawns
- Critical timing: Fast enough to be responsive, slow enough to read
- Player unconsciously prepares for release

### Fireball Impact
- 0.05s expand before explosion
- Makes impact more "readable" and satisfying

### Damage Numbers
- Pop in from zero scale with 1.3x overshoot
- Uses `TRANS_BACK` for bounce-in feel

---

## 3. Staging
**Purpose**: Clear presentation of the action

### Visual Hierarchy
- **Charge indicator**: Grows with attention-grabbing scale changes
- **Screen flash**: At 95% charge, draws eye to center
- **Particles**: Support the main action without overwhelming it

### Color Progression
- Orange → Red → Yellow-White
- Clear visual language: hotter = more powerful
- Reinforces charge percentage without reading UI

---

## 4. Straight Ahead vs Pose-to-Pose
**Approach**: Combination

### Straight Ahead
- Continuous charge growth (per-frame updates)
- Pulsing effect (sine wave-based)
- Fireball bobbing (secondary motion)

### Pose-to-Pose
- Launch sequence (anticipation → launch → follow through)
- Impact sequence (anticipation → explosion)
- Respawn sequence (fade in → pop to scale)

---

## 5. Follow Through & Overlapping Action
**Purpose**: Parts of objects continue moving after the main action stops

### Launch Follow Through
- **Charge indicator**: Expands to 1.5x and fades after fireball spawns
- Duration: 0.2s with cubic easing
- Energy "leaves behind" after release

### Screen Flash Follow Through
- Quick flash in (0.05s)
- Slower fade out (0.3s)
- Mimics how eyes perceive bright light

### Damage Number Follow Through
- Floats upward while fading
- Movement continues after scale animation ends
- Duration: 0.6s total

### Target Respawn
- Scale animation uses `TRANS_ELASTIC`
- Bounces into place rather than instant snap
- Duration: 0.5s for satisfying "pop"

---

## 6. Ease In & Ease Out (Slow In & Slow Out)
**Purpose**: Natural acceleration and deceleration

### Applied Throughout
- **Never using linear interpolation** for animations
- All tweens use `EASE_OUT` with various transitions

### Charge Growth
- Uses exponential ease (`ease(charge_percent, -0.5)`)
- Feels like building pressure/energy
- Not uniform growth rate

### Launch Animations
- `TRANS_CUBIC` for smooth deceleration
- Makes actions feel weighted and intentional

### Impact and Destruction
- `EASE_OUT` + `TRANS_BACK` for bouncy impacts
- `TRANS_ELASTIC` for squash & stretch recovery

---

## 7. Arcs
**Purpose**: Natural motion follows curved paths

### Fireball Bobbing
- Sine wave motion on Y-axis
- Frequency: 0.015 rad/ms
- Amplitude: 2 pixels
- Makes fireball feel alive, not robotic

### Damage Numbers
- Float upward in gentle arc (not straight up)
- Ease-out curve for natural deceleration

---

## 8. Secondary Action
**Purpose**: Supports the main action with additional detail

### Pulsing at High Charge (70%+)
- **Main action**: Charge indicator growing
- **Secondary**: Rhythmic pulsing overlay
- Intensity increases: 8% → 15%
- Speed increases: 0.01 → 0.02
- Doesn't distract from main growth

### Particles
- **Main action**: Fireball traveling
- **Secondary**: Trail particles behind
- **Main action**: Impact
- **Secondary**: Debris particles

### Target Flash
- **Main action**: Squash & stretch on damage
- **Secondary**: Color flash (white → red)
- Runs in parallel without competing

---

## 9. Timing
**Purpose**: Speed creates weight, mood, and personality

### Fast Timings (Snappy)
- Anticipation squash: **0.08s**
- Flash peak: **0.05s**
- Impact expand: **0.05s**
- **Why**: Creates responsive, energetic feel

### Medium Timings (Readable)
- Charge indicator pop-in: **0.15s**
- Launch follow-through: **0.2s**
- Destruction explosion: **0.25s**
- **Why**: Gives player time to read and appreciate

### Slow Timings (Satisfying)
- Flash fade-out: **0.3s**
- Target bounce-in: **0.5s** (with elastic)
- Damage float: **0.6s**
- **Why**: Follow-through needs time to complete

### Rule of Thumb
- Anticipation: Fast (0.05-0.1s)
- Main action: Medium (0.15-0.25s)
- Follow through: Slower (0.3-0.6s)

---

## 10. Exaggeration
**Purpose**: Push beyond realism for emphasis and clarity

### Scale Exaggerations
- Charge indicator: 0.3x → 2.5x (8x range!)
- Max charge pulse: 15% intensity
- Launch squash: 30% horizontal compression
- Explosion: 2x scale expansion
- Target destruction: 2x scale with rotation

### Particle Exaggeration
- Launch particles: 20 → 80 (4x range)
- More particles than "realistic"
- Creates visual impact that reads clearly

### Impact Force
- Target squash proportional to damage
- Visual representation of "ouch"
- Rotation on destruction (extra drama)

---

## 11. Solid Drawing
**Purpose**: Maintain volume and form in all positions

### Scale Consistency
- When squashing horizontally, stretch vertically
- Maintains sense of "mass"
- Example: Launch squash (0.6x, 1.0y) suggests compression, not shrinking

### Fireball Form
- Bobbing motion doesn't affect overall scale
- Rotation follows direction of travel
- Particles trail correctly despite motion

---

## 12. Appeal
**Purpose**: Pleasing, clear, and engaging design

### Clear Visual Language
- Bigger = More powerful
- Brighter/hotter color = More charged
- Faster pulse = Nearly maxed
- Smooth curves, no jarring motions

### Satisfying Feedback Loops
1. Start charge → Immediate pop-in response
2. Hold → Visual feedback every frame
3. Release → Anticipation squash → Launch
4. Hit → Impact squash → Damage number
5. Destroy → Explosion → Wait → Respawn pop

### Personality
- Charge indicator feels "alive" (breathing/pulsing)
- Fireball has "weight" (bobbing, anticipation)
- Targets feel "reactive" (squash on hit)
- Nothing is robotic or linear

---

## Timing Reference Chart

| Action | Duration | Easing | Transition | Purpose |
|--------|----------|--------|------------|---------|
| Charge pop-in | 0.15s | EASE_OUT | TRANS_BACK | Anticipation |
| Launch squash | 0.08s | EASE_OUT | TRANS_ELASTIC | Anticipation |
| Launch follow | 0.2s | EASE_OUT | TRANS_CUBIC | Follow through |
| Flash peak | 0.05s | EASE_OUT | TRANS_CUBIC | Snappy response |
| Flash fade | 0.3s | EASE_OUT | TRANS_CUBIC | Follow through |
| Impact expand | 0.05s | - | - | Anticipation |
| Impact explode | 0.15s | EASE_OUT | TRANS_CUBIC | Main action |
| Target squash | 0.08s | EASE_OUT | TRANS_ELASTIC | Impact reaction |
| Target bounce | 0.3s | EASE_OUT | TRANS_ELASTIC | Recovery |
| Damage pop | 0.1s | EASE_OUT | TRANS_BACK | Anticipation |
| Damage float | 0.6s | EASE_OUT | TRANS_CUBIC | Follow through |
| Destruction | 0.25s | EASE_OUT | TRANS_BACK | Exaggeration |
| Respawn | 0.5s | EASE_OUT | TRANS_ELASTIC | Satisfying entry |

---

## Key Takeaways

### Never Use Linear
- Every tween has easing and transition curves
- Linear motion feels robotic and lifeless
- Even simple actions benefit from ease-in/ease-out

### Anticipation → Action → Follow Through
- Almost every action follows this pattern
- Creates rhythm and satisfying feel
- Makes actions "readable"

### Fast In, Slow Out
- Anticipation should be quick (snappy response)
- Follow through should be slower (satisfying completion)
- Roughly 1:2 to 1:4 ratio

### Squash & Stretch for Impact
- Every collision gets squash & stretch
- Scaled to impact force
- Communicates weight and energy transfer

### Secondary Actions Add Life
- Pulsing, bobbing, floating
- Never compete with main action
- Make world feel alive and reactive

---

## Testing the Principles

Run the experiment and observe:

1. **Does the charge feel alive?** (Pulsing, color shift)
2. **Is the launch satisfying?** (Squash before release)
3. **Do impacts feel powerful?** (Target squashes, damage pops)
4. **Is anything jarring or instant?** (Should be smooth curves)
5. **Can you "read" what's happening?** (Clear staging and timing)

If any action feels "off," check:
- Does it have anticipation?
- Does it have follow-through?
- Is it using easing curves?
- Is the timing appropriate for the mood?

