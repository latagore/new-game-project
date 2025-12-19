# Spell-Casting Game

A top-down action RPG with a typing-as-casting spell mechanic built in Godot 4.5.

## Setup

### Prerequisites
- Godot 4.5+
- curl, unzip (for dev setup)

### Development Setup

Run the setup script to install required addons:

```bash
./scripts/dev-setup.sh
```

Then open the project in Godot and enable the GUT plugin:
1. Project → Project Settings → Plugins
2. Enable "gut"

## Running the Game

- **F5** - Run main scene (`scenes/world.tscn`)
- **F6** - Run current scene

### Combat Prototype (Recommended for Testing)
Open `scenes/prototypes/combat_prototype/combat_prototype.tscn` and press F6.

**Controls:**
- WASD - Move
- Space/Click - Melee attack
- F - Quick fireball
- G - Quick lightning
- Hold 1 - Charge fireball (release to cast)
- Hold 2 - Charge lightning (release to cast)

## Running Tests

```bash
# Run all tests
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit

# Run specific test file
godot --headless -s addons/gut/gut_cmdln.gd -gtest=res://tests/unit/test_spell_manager.gd -gexit
```

## Project Structure

```
scenes/
  player/           # Player character
  enemies/          # Enemy types (static, chasing)
  spells/           # Spell projectiles and effects
  prototypes/       # Test scenes
scripts/
  singletons/       # Autoloaded managers (SpellManager)
  spells/           # SpellData resource class
  ai/               # Enemy AI
resources/
  spells/           # Spell definitions (.tres)
tests/
  unit/             # Unit tests
  integration/      # Integration tests
ui/                 # UI components
```
