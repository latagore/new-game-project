# Micro vs Macro: Five Design Approaches

Exploring different ways to balance moment-to-moment action (micro) with strategic awareness (macro) in a spell-casting action game.

---

## Design 1: Action Core + Ritual Spells at Critical Moments

**Micro:** Hack-and-slash or twin-stick shooter. Dodging, aiming, positioning.
**Macro:** Resource management, enemy prioritization, when to commit to a big spell.

### How It Works
- Normal gameplay is pure action: click to attack, WASD to move, dodge roll
- Spells are **rituals** that require typing/input during combat lulls or as high-risk plays
- Typing a spell locks you in place—you're vulnerable but charging something powerful

### Spell Examples
| Spell | Input | Effect |
|-------|-------|--------|
| Fireball | Type "fire" | Standard projectile, quick |
| Meteor | Type "cataclysm" | Screen-clearing nuke, 2sec channel |
| Time Stop | Type "chronos" | Freeze enemies, gives breathing room |

### Macro Tension
- **When do I commit?** Typing during combat is risky. You must create safe windows.
- **Enemy pressure** determines spell choice—can I afford 2 seconds for Meteor, or do I need quick Fireball?
- Boss fights have **DPS check phases** where you MUST land big spells to break shields

### Feels Like
Bayonetta meets The Typing of the Dead. Action flows naturally, spells are punctuation marks.

---

## Design 2: Spells as Macro Setup, Action as Execution

**Micro:** Execute combos, dodge, aim within spell-created zones.
**Macro:** Pre-positioning spells to control the battlefield.

### How It Works
- Spells don't deal direct damage—they **create zones or modify terrain**
- Your action attacks deal damage, but spells multiply effectiveness
- The game becomes: set up the board, then execute

### Spell Examples
| Spell | Effect |
|-------|--------|
| Gravity Well | Pull enemies to a point over 3 seconds |
| Oil Slick | Zone that slows enemies, amplifies fire damage |
| Lightning Rod | Place a rod; your attacks arc to it, chaining through enemies |
| Mirror Image | Clone that enemies target; you flank |

### Macro Tension
- **Positioning is everything.** A well-placed Gravity Well + Oil Slick + Fireball = room clear
- Spells have **cooldowns**, so you plan 30 seconds ahead
- Enemy spawn patterns become puzzles: where do I put my zones?

### Feels Like
Magicka meets XCOM. You're a battlefield architect who also does the demolition.

---

## Design 3: Spell Economy with Macro Costs

**Micro:** Casting spells quickly and accurately.
**Macro:** Managing the downstream consequences of casting.

### How It Works
- Every spell has a **macro cost** beyond mana:
  - **Heat**: Fire spells build heat. Overheat = you take damage
  - **Attention**: Complex spells draw enemy aggro
  - **Positioning**: Some spells root you or push you backward
  - **Tempo**: Long spells give enemies free actions

### Spell Cost Examples
| Spell | Power | Cost |
|-------|-------|------|
| Spark | Low | None—spam freely |
| Fireball | Medium | +30 Heat (100 = overheat) |
| Firestorm | High | +80 Heat, 1.5s root |
| Blizzard | High | Slows YOU by 30% for 5s |
| Thunder | Medium | Enemies aggro you for 3s |

### Macro Tension
- **Resource curves**: You can burst hard early, but overheat = vulnerability
- **Aggro management**: Big spells paint a target on you. Do you have an escape plan?
- **Cooldown vs Cost**: Quick spells have low cooldowns but build heat. Big spells have long cooldowns but are "free" in terms of heat.

### Feels Like
Monster Hunter spell management. Every action has weight and consequence.

---

## Design 4: Reactive Spells (Counter System)

**Micro:** Reading enemy tells, executing counters with precise timing.
**Macro:** Tracking multiple enemies, prioritizing which attacks to counter.

### How It Works
- Enemies have **telegraphed attacks** with specific counters
- Typing the counter spell during the telegraph **negates and punishes**
- Wrong counter or missed timing = you take the hit

### Counter Examples
| Enemy Attack | Tell | Counter Spell | Punish |
|--------------|------|---------------|--------|
| Fireball | Red glow, 1s windup | "aqua" | Reflect back |
| Charge | Enemy crouches | "stone" | Enemy hits wall, stunned |
| Beam | Laser sight appears | "mirror" | Beam bounces to other enemies |
| Summon | Magic circle forms | "dispel" | Summon fails, caster stunned |

### Macro Tension
- **Triage**: Three enemies winding up. Which do you counter? You can only type one spell.
- **Priority targets**: The summoner's summon is more dangerous than the grunt's fireball
- **Positioning**: Get hit by one attack to dodge into position for a better counter?

### Feels Like
Sekiro parry system meets typing. Reactive, read-based gameplay.

---

## Design 5: Spell Buffs that Modify Action Gameplay

**Micro:** Your attack patterns change based on active spell buffs.
**Macro:** Choosing which buff to activate for the current situation.

### How It Works
- Spells don't attack—they **buff your basic attacks** for a duration
- Different buffs dramatically change how your attacks work
- Only one buff active at a time; switching has a cooldown

### Buff Examples
| Spell | Duration | Effect on Attacks |
|-------|----------|-------------------|
| "flame" | 8s | Attacks leave burning ground |
| "frost" | 8s | Attacks slow, 3 slows = freeze |
| "spark" | 8s | Attacks chain to nearby enemies |
| "void" | 8s | Attacks pull enemies toward impact |
| "haste" | 5s | Attack speed 2x, but 50% damage |

### Macro Tension
- **Situational awareness**: Swarm? Use spark chains. Boss? Use frost for CC.
- **Buff timing**: Buff expires mid-fight. Do you re-cast same buff or adapt?
- **Commitment**: Switching buff costs a cooldown. Choose wrong = 10 seconds of bad matchup.

### Feels Like
Diablo 3 elemental builds meets stance-switching. Your spell choice defines your playstyle moment-to-moment.

---

## Comparison Matrix

| Design | Micro Focus | Macro Focus | Skill Expression |
|--------|-------------|-------------|------------------|
| 1. Action + Rituals | Dodge, aim, attack | When to cast big spells | Typing under pressure |
| 2. Setup + Execute | Combo execution | Zone placement | Spatial planning |
| 3. Spell Economy | Cast accuracy | Resource curves | Risk management |
| 4. Counter System | Read tells, react | Triage multiple threats | Pattern recognition |
| 5. Buff Modifiers | Adapt attack patterns | Buff selection | Situational awareness |

---

## Hybrid Potential

These aren't mutually exclusive. A strong design might combine:

- **Design 1's ritual spells** for ultimates
- **Design 3's heat system** to prevent spell spam
- **Design 5's buff system** for moment-to-moment variety

Example flow:
1. Type "flame" to buff attacks (Design 5)
2. Hack-and-slash with fire attacks, building Heat (Design 3)
3. Create an opening, type "cataclysm" for meteor (Design 1)
4. Heat resets, switch to "frost" for crowd control

---

## Next Steps

1. **Pick 1-2 designs** to prototype deeper
2. **Identify the core loop**: What does 10 seconds of gameplay look like?
3. **Paper test**: Can you explain the macro decisions to a friend without the game?
4. **Prototype the tension**: Build the scenario that forces the macro decision

Which design resonates most with your vision?
