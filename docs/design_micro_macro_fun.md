## Designing Fun Through Micro–Macro Tension (Action Spellcasting)

### Thesis
Create sustained fun by forcing constant tradeoffs between tactical, time-pressured spell execution (micro) and strategic, longer-horizon goals (macro). Players juggle precise inputs, positioning, and environmental manipulation while making route, objective, and resource decisions that pay off minutes later.

### Inspirations: How Great Games Balance Micro vs Macro
- **League of Legends**
  - **Micro**: Last-hitting, dodging skillshots, input-tight combos, short cooldown windows.
  - **Macro**: Wave control, rotations, objective timing (dragon/baron), vision setup, power spike planning.
  - **Tension Pattern**: Commit to a micro trade now vs holding the wave/timers for future advantage.
- **Barotrauma**
  - **Micro**: Repairing leaks, treating injuries, manual device ops, small-arms combat, triage in seconds.
  - **Macro**: Mission routing, crew roles, submarine loadout, power/oxygen systems management.
  - **Tension Pattern**: Fix the urgent leak or maintain system integrity for the next encounter.
- **Dome Keeper**
  - **Micro**: Mining patterns, carry weight, precise combat parries/aim during waves.
  - **Macro**: Split-time management between mining and defense, upgrade tech path, route planning.
  - **Tension Pattern**: Dive deeper now (risk) vs return early to hold the wave (safety).

### Design Pillars
- **Intentful Time Pressure**: Short micro windows nested inside predictable macro beats (cycles, alarms, boss turns).
- **Tradeoffs Everywhere**: Every micro commitment has a macro cost (position, cooldown, resource, reveal).
- **Systemic Interactions**: Spells change the environment and vice versa (materials, elements, hazards).
- **Readable Complexity**: Complex inputs are challenging but forgiving; mastery deepens options, not gatekeeps basic fun.
- **Plan–Prepare–Execute Loop**: Players plan routes/builds, prepare states, and execute under stress.

### Core Loop (90–120s macro cycle with 3–8s micro pockets)
1. **Scout/Plan**: Identify objectives, threats, environmental affordances.
2. **Prepare**: Set stances, preload runes, position, tag terrain (wet/charged/brittle).
3. **Execute**: Cast under time pressure, react to enemy telegraphs, leverage environment.
4. **Stabilize**: Convert short-term wins into macro gains (objectives, upgrades, map control).
5. **Rotate**: Move to next objective as timers and hazards evolve.

### Spellcasting Model: Complex but Fair
- **Input Schemes**
  - **Chorded Inputs**: Hold + tap sequences (e.g., Hold Q, tap A, release) for compact, discoverable combos.
  - **Gestures**: Directional flicks or shape draws with leniency windows and snap-to recognition.
  - **Sequenced Runes**: Queue 2–3 runes into a stance; releasing casts a composite spell.
- **Forgiveness & Clarity**
  - **Input Buffer** (200–350 ms) and **leniency windows** so slight errors still map to intended spell family.
  - **Preparation Stances**: Safe window to assemble spells at reduced movement; cancels cost focus, not the whole cast.
  - **Partial Success**: Miscasts trigger a weaker, safer variant with a unique side effect instead of pure failure.
  - **Quick-Cast vs Confirm**: Toggle per spell; confirm adds micro tax but prevents unwanted commits.
  - **Stability Meter**: Errors reduce stability; at low stability, spells risk backlash or sputter (soft fail, readable).
- **Resources & Cooldowns**
  - **Focus** (regenerates fast for micro loops) vs **Essence** (slow, macro-limited) + **Heat/Overcast** that decays over time.
  - **Long CDs** are macro levers; **short CDs** are micro tempo tools.
- **Loadouts & Adaptation**
  - Pre-run loadouts (macro identity) + in-run pickups/mods (micro adaptation).
  - Two interchangeable stances to swap tactical kits without menuing.

### Systemic Environment & Enemy Interactions
- **Material Tags**: Wet, Charged, Brittle, Combustible, Overgrown, Slippery.
- **Spell–World Synergies**
  - Lightning chains better on Wet; Fire consumes Overgrown to create Ash clouds; Frost on Brittle causes shatter AOEs.
  - Terrain sculpting: Erode sand, freeze water bridges, overcharge pylons, vent steam curtains.
- **Enemy Ecologies**
  - Factions pursue objectives (sabotage pylons, harvest nodes, call reinforcements) to generate macro stakes.
  - Telegraphs readable at 0.7–1.0s to preserve fairness; elites bend macro rules (delay timers, corrupt terrain).

### Objectives and Macro Beats
- **Short-Term**: Survive wave, escort beam charge, protect relay, capture vents.
- **Mid-Term**: Route selection, unlock shortcuts, construct limited defenses, seed environmental traps.
- **Long-Term**: Tech path (spell schools, stance upgrades), map control, boss keys.

### Not Solo Puzzle: Interaction First
- **Ambient Systems**: Moving hazards, drifting resources, autonomous devices create emergent opportunities.
- **NPC/Enemy Pressure**: Enemies constantly alter the board (flood, burn, fortify), forcing reactive casts.
- **Soft Cooperation** (even solo): Devices require upkeep while you cast; choose when to commit hands-off time.

### Keeping Execution Demanding but Not Oppressive
- **Design Guardrails**
  - Input challenges are time-bounded and chunked; most encounters can be solved with 2–3-spell chains.
  - Missed precision yields reduced effect, not a full reset.
  - Macro choices (positioning, objective timing) can redeem imperfect micro.
- **Assist Options**
  - Aim magnetism tiers, gesture auto-complete, slower focus drain, extended buffers; disable for higher rewards.

### UI/UX for Readability Under Stress
- **Intent Preview**: Ghost reticles and concise rune tooltips during stances.
- **Input HUD**: Recent input strip with error highlights; teachable moments without pausing.
- **World Tags**: Subtle decals on tagged terrain; color-safe element palette.
- **Macro Timers**: Clear objective clocks and rotation prompts; never more than 3 concurrent critical timers.

### Tuning Knobs
- Buffer size; stability decay/recovery; partial success coefficients; overcast heat; CD tiers; tag durations; enemy telegraph times; macro cycle lengths (e.g., 90/120s); assist strength scaling; reward multipliers.

### Example Scenarios
- **Storm the Relay**: You must overcharge a pylon before a 120s enemy rally.
  - Micro: Chain Wet → Lightning while dodging elites; quick-cast arcs to clear adds.
  - Macro: Delay overcharge to bait elite spawn timings; freeze water to create safe lanes.
- **Ash Harvest**: Burn overgrowth for resources while defending vents.
  - Micro: Fire cones with gesture confirm; partial miscasts create Smoke that obscures sniper telegraphs.
  - Macro: Route through combustible corridors to set future kill zones.

### Progression & Meta
- Unlock spell schools and stance mods that alter cast ergonomics (wider leniency, alternate chords).
- Map meta: persistent shortcuts, device blueprints; higher risk routes raise reward multipliers.

### Difficulty & Director
- Encounter director monitors stability, resource state, and timer margin to tune spawn intensity and hazards.
- Rubberband via tag opportunities (free Wet zones) rather than raw HP sponges.

### Accessibility Options
- Remap inputs; left/right-handed chord modes; adjustable buffer/gesture leniency; colorblind-safe tags; practice arena with slow-time.

### Prototype Next Steps (Godot)
- Implement 3 spells: Bolt (Lightning, chorded), Frost Lance (gesture), Fire Cone (sequenced runes).
- Add 3 tags: Wet, Brittle, Combustible with 2 interactions each.
- Create 1 elite + 2 fodder enemy archetypes with clear telegraphs.
- Add a 120s macro cycle with a pylon objective and wave interludes.
- Build input HUD (buffer strip, stance preview) and tag decals.

### Risks & Mitigations
- Execution overload → Buffer/stance safety nets, partial success, assist tiers.
- Visual clutter → Cap concurrent critical timers; prioritize telegraph hierarchy; conservative VFX brightness.
- Shallow macro → Ensure objectives and routes materially change risk/reward and future states.


