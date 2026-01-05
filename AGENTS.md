# AI Agent Instructions

Guidelines for AI agents (Claude, Copilot, etc.) working on this codebase.

---

## Required Reading

### Godot Quirks
**Always refer to [`godot_quirks.md`](./godot_quirks.md)** before writing Godot code.

This file documents common pitfalls and syntax gotchas specific to Godot 4.x. When you encounter a new quirk or bug caused by Godot-specific behavior, **update the file** with:
- The problematic pattern (BAD example)
- The correct approach (GOOD example)
- Brief explanation of why

---

## Project Conventions

### File Organization
- Scenes: `scenes/<category>/<name>.tscn`
- Scripts: Colocated with scenes, or in `scripts/` for shared logic
- Resources: `resources/<type>/<name>.tres`
- Tests: `tests/unit/` and `tests/integration/`

### Naming
- snake_case for files and folders
- PascalCase for class names
- snake_case for variables and functions

### Testing
- Run tests before committing: `godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit`
- Add tests for new features in appropriate `tests/` subfolder

---

## When You Find a Bug

1. Check `godot_quirks.md` - it might already be documented
2. If it's a new Godot quirk, add it to the file
3. If it's project-specific, fix it and add a test

---

## Key Files

| File | Purpose |
|------|---------|
| `godot_quirks.md` | Godot 4.x pitfalls and solutions |
| `CLAUDE.md` | Project overview and architecture |
| `docs/PLAN.md` | Development roadmap |
| `scripts/dev-setup.sh` | Install dev dependencies |
