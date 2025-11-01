# Minimal Prototype Experiments
*Tiny, testable game prototypes (Pong/Tetris-sized) to validate core mechanics*

---

## Input Complexity

### Q1: What input complexity level feels good?
**Mini-Game: Simon Says Combat**
- Screen shows 3 colored circles, flash a sequence (2-4 inputs)
- Player recreates sequence to "cast spell" and damage the enemy square
- Enemy square shoots projectile every 3 seconds
- Test variants: 2-input / 3-input / 4-input sequences
- Measure: completion rate, time to complete, subjective fun rating

**Mini-Game: Hold & Tap**
- Hold Space, tap Q/W/E in different combos (e.g., Space+Q, Space+Q+E)
- Each combo makes colored square appear
- Test: sequential (Q then W) vs chorded (Q+W together) vs hold-modifier (Hold+Q)
- Measure: input error rate, preference rating

**Mini-Game: Shape Tracer**
- Draw arrow shapes with mouse (up, down, left, right, diagonal)
- Each shape shoots projectile at slowly approaching enemy
- Test: 4 recognition strictness levels (very loose to very tight)
- Measure: misrecognition frustration, speed of input

### Q2: Do input buffers reduce frustration?
**Mini-Game: Button Rush**
- Press Q-W-E sequence when circle flashes
- Test: 0ms / 100ms / 200ms / 400ms buffer between inputs
- Enemy approaches, you must complete sequence before it reaches you
- Measure: success rate per buffer size, perceived fairness

### Q3: Does partial success feel better than binary fail?
**Mini-Game: Casting Practice**
- Click 3 targets that appear in sequence within 2 seconds
- Variants: (A) hit all 3 or deal no damage, (B) deal damage proportional to hits (1/3, 2/3, 3/3)
- 10 rounds per variant
- Measure: frustration rating, engagement rating

---

## Cooldown Strategy

### Q4: What cooldown length creates strategic tension?
**Mini-Game: Button Timer**
- You have one button that kills all enemies on screen
- Enemies spawn every 2 seconds
- Test: cooldown of 3s / 6s / 12s / 20s
- Goal: survive 60 seconds
- Measure: usage pattern, "saved it too long" vs "used too early" feelings

**Mini-Game: Two Button Problem**
- Button A: 3s cooldown, kills 1 enemy
- Button B: 15s cooldown, kills all enemies
- Enemies spawn randomly
- Test: Does player use B strategically or hoard it?
- Measure: average B usage timing, final score variance

### Q5: Do vulnerability windows create MOBA-style tension?
**Mini-Game: Armored Enemy**
- Enemy has shield (gray) and vulnerable state (red) alternating every 5 seconds
- You have ultimate ability on 8-second cooldown
- Hitting during vulnerable = 3x damage
- Test: Does waiting for vulnerable window feel strategic or annoying?
- Measure: timing accuracy, decision satisfaction

**Mini-Game: Wave Cooldown**
- 5 waves of enemies with 10s gap between waves
- You have 1 powerful ability with 15s cooldown
- Test: Players must choose which wave to use it on
- Measure: decision variance, regret/"should have saved it" reports

### Q6: Can cooldowns alone be fun without execution complexity?
**Mini-Game: Auto-Aim Buttons**
- 3 buttons (A/B/C), each auto-kills certain enemy type
- Enemies spawn in patterns
- A: 2s CD, kills red
- B: 5s CD, kills blue  
- C: 10s CD, kills both
- Test: Pure decision-making, zero execution
- Measure: engagement rating, "puzzle feel" vs "action feel"

---

## Micro vs Macro Tension

### Q7: Can players handle execution + timer pressure?
**Mini-Game: Asteroid Dodge + Timer**
- Asteroids fall, you dodge (arrow keys)
- Timer counts down from 30 seconds
- Must survive until timer expires
- Test: Does timer increase tension or just stress?
- Measure: difficulty perception, fun vs stress ratio

**Mini-Game: Collect Under Fire**
- Coins spawn on screen, enemies shoot projectiles
- Must collect 10 coins to win
- Test: Resource collection during combat pressure
- Variants: coins disappear after 5s vs permanent
- Measure: strategy emergence, frustration

### Q8: What time scale feels best for macro objectives?
**Mini-Game: Survival Timer**
- Survive enemy waves while timer counts down
- Test: 20s / 45s / 90s / 180s durations
- Same enemy density per second
- Measure: perceived encounter length satisfaction, "too short/long" ratings

**Mini-Game: Wave Upgrade**
- Endless waves, pick 1 of 3 upgrades every N seconds
- Test: upgrade every 15s vs 60s vs 180s
- Measure: decision meaningfulness, pacing satisfaction

### Q9: Does split attention create good tension?
**Mini-Game: Repair & Dodge**
- Hold Space to repair health bar while dodging projectiles (arrow keys)
- Can't repair while moving
- Must reach 100% health to win
- Measure: tension rating, fun vs frustration

---

## Strategic Outplay Feel

### Q10: Does the "perfect moment" feel satisfying?
**Mini-Game: Stun the Charge**
- Enemy charges up 3-second attack (progress bar)
- Press Space to interrupt during charge
- Success = big damage, failure = take damage
- Variants: can interrupt anytime vs only during last 0.5s
- Measure: satisfaction on success, risk/reward feel

**Mini-Game: Save for Boss**
- 3 weak enemies, then 1 strong enemy
- You have 1 powerful ability
- Test: Do players save for boss or use early?
- Measure: usage patterns, regret/satisfaction

### Q11: Do combos create satisfying decisions?
**Mini-Game: A+B Combo**
- Button A: shoots red projectile, 3s cooldown
- Button B: shoots blue projectile, 3s cooldown
- Variant A: A and B each do 1 damage
- Variant B: A then B (within 2s) does 3 damage total
- Test: Does combo system change decision-making?
- Measure: combo usage rate, strategic feel

**Mini-Game: Element Mixer**
- 3 buttons drop colored balls into enemy area (fire/ice/lightning)
- Test: no interactions vs fire+ice=steam (stun) vs ice+lightning=freeze
- Measure: experimentation behavior, discovery satisfaction

### Q12: Can positioning be strategic without complexity?
**Mini-Game: Range Zones**
- Enemy in center, you can move to 3 zones (close/medium/far)
- Attack button does 3/2/1 damage at close/medium/far
- Enemy only attacks close range
- Test: Does positioning choice feel strategic?
- Measure: movement patterns, risk/reward decision-making

---

## Forgiveness

### Q13: How much forgiveness feels right?
**Mini-Game: Dodge Test**
- Enemy shoots projectile every 3 seconds
- Press Space to dodge
- Test: i-frame duration: 0ms / 200ms / 400ms / 800ms
- Measure: success rate, perceived fairness

**Mini-Game: Health Bars**
- Same enemy, same attacks
- Test: 3 HP vs 10 HP vs 30 HP
- Measure: tension level, allowance for mistakes feel

### Q14: Does partial success feel better?
**Mini-Game: Miss Penalty**
- Click targets to survive
- Variant A: miss = instant death
- Variant B: miss = lose 1 of 3 lives
- Variant C: miss = timer penalty (+2 seconds)
- Measure: frustration, retry willingness

**Mini-Game: Imperfect Cast**
- Press Q-W-E combo, timing matters
- Variant A: wrong timing = no spell
- Variant B: wrong timing = 50% damage spell
- Variant C: wrong timing = different random spell
- Measure: engagement, "interesting failure" rating

---

## Telegraph & Pattern Recognition

### Q15: What telegraph timing is fair?
**Mini-Game: Red Alert**
- Enemy flashes red, then attacks your position
- Test: warning duration: 0.2s / 0.5s / 1.0s / 1.5s
- Must move before attack lands
- Measure: success rate curve, fairness perception

**Mini-Game: Audio vs Visual**
- Enemy attacks every 5 seconds
- Variant A: visual flash only
- Variant B: sound cue only
- Variant C: both
- Measure: reaction success, preference

### Q16: Do learnable patterns feel good?
**Mini-Game: Pattern Enemy**
- Enemy does sequence: Attack, Wait, Attack, Wait, Attack, BIG ATTACK
- Pattern repeats identically
- You time your ability to hit during big attack windup
- Test: Does learning pattern feel rewarding?
- Measure: death count to mastery, satisfaction on pattern recognition

**Mini-Game: Random vs Pattern**
- Variant A: enemy attacks in fixed 3-move loop
- Variant B: enemy attacks randomly
- Same average difficulty
- Measure: frustration, skill expression feeling

---

## Resource Management

### Q17: Single vs dual resources?
**Mini-Game: Mana Bar**
- Ability costs mana (regens 10/sec)
- Variant A: 100 mana, ability costs 30
- Variant B: 100 mana + 3 charges (regens 1 charge/10s)
- Enemy waves attack
- Measure: strategic depth feel, complexity vs depth

**Mini-Game: Regen Speed**
- Spam ability to kill enemies
- Test: regen rate 5/sec vs 20/sec vs instant
- Measure: pacing feel, spam vs conserve behavior

### Q18: Does scarcity add tension or annoyance?
**Mini-Game: Mana Scarcity**
- Variant A: abundant mana (never run out)
- Variant B: tight mana (run out frequently)
- Same enemies
- Measure: tension vs frustration, strategic vs annoying

---

## Pattern Integration

### Q19: Can micro + macro coexist?
**Mini-Game: Combo Under Timer**
- Press Q-W-E sequence to deal damage
- 30-second survival timer
- Enemies approach continuously
- Test: Can player execute combos while tracking timer?
- Measure: cognitive load, overload threshold

**Mini-Game: Cooldown + Execution**
- Input 3-button sequence (micro)
- But ability has 10s cooldown (macro)
- Test: Does cooldown make execution more or less satisfying?
- Measure: pacing feel, cooldown frustration vs strategic tension

### Q20: What's the minimum fun version?
**Mini-Game: One Button Boss**
- One button on cooldown
- Boss has pattern
- Press button at optimal time
- Test: Is this engaging despite simplicity?
- Measure: baseline fun, "needs more" feedback

**Mini-Game: Pure Timing**
- No complex inputs, just "press Space at right time"
- Enemy vulnerable window flashes
- Cooldown 8s, vulnerable window every 6s
- Test: Is pure timing satisfying?
- Measure: frustration vs satisfaction, MOBA-feel rating

---

## Implementation Notes

Each prototype should:
- Be buildable in 1-4 hours
- Have clear victory/loss condition
- Test ONE variable
- Be playable by others for feedback
- Track metrics: success rate, time to complete, subjective ratings (1-5 scale)

Recommended order:
1. Start with cooldown experiments (easiest to implement)
2. Move to forgiveness/telegraph (teaches enemy design)
3. Then input complexity (most iteration needed)
4. Finally integration experiments (validates full system)

