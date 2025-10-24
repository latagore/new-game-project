# Master TODO - Game Feature Development

This document serves as the central planning hub for new features and systems to be implemented in the game.

## Overview

This project is a top-down action RPG with a unique spell-casting system based on typing magic phrases. The player combines melee combat with powerful arcane spells to defeat enemies.

## Feature Implementation Documents

### 1. Projectile and Laser System
**Status:** Planning  
**Document:** [projectile_laser_system.md](./projectile_laser_system.md)  
**Priority:** High

Implements a comprehensive projectile and hitscan laser system for magic spells, expanding the spell system beyond instant-effect abilities.

**Key Components:**
- Projectile spawning and movement system
- Hitscan laser implementation
- Collision detection with hitboxes
- Extensible architecture for future spell types
- Visual rendering considerations

### 2. [Future Feature Placeholder]
**Status:** Not Started  
**Document:** TBD

### 3. [Future Feature Placeholder]
**Status:** Not Started  
**Document:** TBD

## Development Principles

1. **Incremental Development:** Build features in stages, ensuring each stage is playable
2. **Integration First:** New systems should integrate cleanly with existing code (spell_manager, hitbox/hurtbox, etc.)
3. **Extensibility:** Design with future expansion in mind
4. **Performance:** Consider performance implications, especially for particle systems and collision checks

## Current Game State

- ✅ Core player movement and melee combat
- ✅ Basic enemy with health system
- ✅ Hitbox/Hurtbox collision system
- ✅ Spell casting UI with typing mechanic
- ✅ Instant-effect spells (destroy all enemies, freeze all)
- 🔄 Stage 2: Arcane Transcription (Magic System) - In Progress
- ⏳ Stage 3: Expanding the Core Loop - Planned

## Notes

- Collision layers in use: Layer 2 (Hitboxes), Layer 4 (Hurtboxes)
- Current spell system is in `scripts/singletons/spell_manager.gd`
- Visual effects are in `scenes/effects/`
