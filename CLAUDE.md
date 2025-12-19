# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **Godot 4.5** top-down action RPG with a unique "typing-as-casting" spell mechanic. Players move and attack traditionally, but cast spells by entering a typing mode and transcribing magic phrases (e.g., "IGNIS MAJORIS").

## Running the Game

Open the project in Godot 4.5+ and press F5 to run the main scene (`scenes/world.tscn`).

To run experiments:
- Open any experiment scene in `scenes/experiments/` and press F6 (Play Scene)
- Current experiments: `fireball_charge/`, `lightning_charge/`, `performance_tests/`

## Architecture

### Core Game Loop
- **Player** (`scenes/player/player.gd`): CharacterBody2D with movement, melee attack, and spell casting
- **Enemy** (`scenes/enemies/enemy.gd`): Basic enemies with hurtboxes
- **World** (`scenes/world.tscn`): Main game scene

### Spell System
The spell system uses a "typing-to-cast" mechanic:

1. Player presses Enter → enters casting mode (movement disabled)
2. `SpellCastUI` displays a spell phrase to transcribe
3. Player types the phrase correctly → `spell_cast_success` signal emitted
4. `SpellManager` singleton executes the spell effect

**Key files:**
- `scripts/singletons/spell_manager.gd` - Autoload singleton, spell registry and effect execution
- `ui/spell_cast_ui.gd` - Typing UI and input validation

### Combat Components
Hitbox/Hurtbox pattern using Area2D:
- `scripts/components/hitbox.gd` - Deals damage (Layer 2)
- `scripts/components/hurtbox.gd` - Receives damage (Layer 4)

### Planned Architecture (see docs/)
The codebase is evolving toward a **data-driven spell system**:
- Spell configurations as `.tres` Resources
- Reusable behavior scripts for projectiles, lasers, AoE
- Visual scenes separate from logic
- See `docs/spell_architecture_responsibilities.md` for the target architecture

## Key Conventions

### Collision Layers
- Layer 2: Hitboxes (player attacks)
- Layer 4: Hurtboxes (damageable areas)
- Layer 8: Projectiles (proposed)

### Input Actions (defined in project.godot)
- `left/right/up/down` or `A/D/W/S` - Movement
- `attack` - Left mouse button or Space
- `ui_accept` (Enter) - Enter spell casting mode

### Node Groups
- `"player"` - Player node
- `"enemies"` - All enemy nodes
- `"spell_ui"` - Spell casting UI

## Documentation

Key design documents in `docs/`:
- `PLAN.md` - Development stages roadmap
- `spell_architecture_responsibilities.md` - Target spell system architecture
- `projectile_laser_system.md` - Projectile/laser implementation details
- `master_todo.md` - Feature planning hub

Experiment documentation in `scenes/experiments/README.md`.
