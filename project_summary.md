# My2048 - Project Implementation Summary

This document summarizes the features, logic, and UI enhancements implemented in the Flutter 2048 game for use with AI assistants or documentation.

## 🚀 Core Features & Gameplay
- **Standard 2048**: Classic grid-based merging logic.
- **Timer Challenge Mode**: 
  - Two targets: **1024** (300s) and **2048** (360s).
  - **Dynamic Bonus Time**: Merging tiles (64 and above) grants extra time (+10s to +40s).
- **Power-Ups**:
  - **Undo**: History-based reversal of the last 10 moves (state-buffered).
  - **Swap Tiles**: Strategic ability to select and swap any two tiles on the board.
- **Persistence**: 
  - Saves/Loads High Score, Selected Theme, and last Game Mode using `shared_preferences`.

## 🎨 UI & UX Enhancements
- **Responsive Layout**: 
  - The board dynamically resizes to fill available space while maintaining a perfect square aspect ratio.
  - Header adapts to "Time Challenge" mode: Game title pinned top-left, Score and Timer grouped top-right.
- **Modern Controls**:
  - Core action buttons (Undo, Swap, New) are **100x100 squares** with vertical Icon/Text stacking.
- **Settings System**:
  - Centered `Dialog` with a fixed **390px width** for a premium look.
  - Custom scrollbar and 30px rounded corners.
  - 6 Built-in Themes: Rhino Grey, Turtle Green, Rare Indigo, Sunset Orange, Oceanic Blue, Arctic White.

## ✨ Animation & Visual Feedback
- **2048.co Style Motion**:
  - Snappy **100ms** tile sliding for high responsiveness.
  - **200ms** merge "pop" effect (1.15x scale bounce).
  - **200ms** zoom-in entrance for new tiles.
- **Physical Feedback**:
  - **Screen Shake**: Triggered via `AnimationController` on major merges (1024+).
  - **Confetti**: 7-second celebration using the `confetti` package.
- **Dynamic Timer**:
  - Background color shifts: Green (Safe) → Yellow → Orange (Pulsing) → Red (Critical Pulsing).
- **Floating Text**: 
  - Bonus time awards (+Xs) float and fade upwards from the board using a custom `_BonusTimeAnimation` overlay.

## 🛠 Tech Stack Details
- **State Management**: `Provider` (using `MultiProvider` for Game and Theme states).
- **Navigation/Modals**: Custom Material 3 Dialogs and responsive LayoutBuilders.
- **Input**: Unified handling for **Touch Swipes** and **Keyboard Arrow Keys**.
- **Dependencies**: 
  - `provider`, `shared_preferences`, `confetti`, `uuid`.

## 📂 Project Structure
- `lib/features/game/models/tile.dart`: Data structure with `isMerged`, `isNew`, and `isDeleting` flags.
- `lib/features/game/providers/game_provider.dart`: Core logic, timer, and persistence.
- `lib/features/game/ui/game_screen.dart`: Main UI, animations, and responsive header logic.
- `lib/features/settings/providers/theme_provider.dart`: Theme definitions and persistence.
- `lib/features/settings/ui/settings_dialog.dart`: Settings interface.
