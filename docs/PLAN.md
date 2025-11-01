# Game Development Plan

This document outlines the development stages for our top-down action RPG.

## Stage 1: Core Gameplay Bootstrap (The "Toy")

The goal of this stage is to create a minimal, playable slice of the game. We want to get a character moving and fighting as quickly as possible, ignoring non-essential features like menus or complex UI for now.

**Tasks:**

1.  **Player Setup:**
    *   Create a `Player` scene (`CharacterBody2D`).
    *   Implement basic top-down movement (up, down, left, right).
    *   Implement a single melee attack (e.g., a sword swing) with a corresponding `Hitbox` (`Area2D`) to register damage.
    *   Add a `Hurtbox` (`Area2D`) to the player to detect incoming damage.

2.  **Basic Enemy:**
    *   Create a simple `Enemy` scene (`CharacterBody2D`).
    *   For now, the enemy will be static (no movement or AI).
    *   It will have a `Hurtbox` to take damage and a simple health variable.
    *   On taking enough damage, it will disappear (using `queue_free()`).

3.  **Minimalist World:**
    *   Create a `World` scene.
    *   Use a simple `ColorRect` for the ground.
    *   Place one instance of the `Player` and a few instances of the `Enemy` in the `World`.

**Goal of Stage 1:** A playable scene where the player can move around and destroy stationary enemies. This validates the core combat and movement mechanics.

---

## Stage 2: Arcane Transcription (Magic System)

This stage implements the unique spell-casting mechanic.

**Tasks:**

1.  **Casting Mode:**
    *   On pressing the "Enter" key, the game will pause player movement and enter a "typing mode".
2.  **UI Implementation:**
    *   A text input box will appear on the screen.
    *   A "spell transcript" (a phrase of magic words, e.g., "IGNIS MAJORIS") will be displayed to the player.
3.  **Transcription Logic:**
    *   The system will check the player's typed input against the required spell transcript.
    *   If the player types the phrase correctly and presses "Enter" again, a "spell success" signal is emitted.
    *   If the player cancels (e.g., presses `Esc`), the mode is exited.
4.  **Placeholder Spell Effect:**
    *   Upon successful casting, a simple, powerful effect will occur. For this stage, we can make it destroy all enemies on the screen.

**Goal of Stage 2:** Implement and test the core "typing-as-casting" mechanic.

---

## Stage 3: Expanding the Core Loop

*(This was the old Stage 2)*

Now we will make the combat more dynamic and add feedback.

**Tasks:**

1.  **Enhanced Player Mobility:**
    *   Implement a dodge or dash ability.
2.  **Dynamic Enemy:**
    *   Implement basic enemy AI, allowing them to chase and attack the player.
3.  **Core UI & Feedback:**
    *   Create a HUD for player health.
    *   Add visual feedback for taking damage.
    *   Add health bars above characters.
4.  **Game Management:**
    *   Create a `GameManager` to handle game state (like restarting).

**Goal of Stage 3:** A more engaging combat loop where the player must use melee, magic, and dodging to defeat enemies that actively fight back.
