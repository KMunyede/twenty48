# My2048 - Premium Cross-Platform Puzzle Game

A modern, feature-rich implementation of the classic 2048 puzzle, built with Flutter and Provider.

## 🚀 Game Features
- **Dual Game Modes**: 
  - **Standard 2048**: Classic grid-merging gameplay.
  - **Timer Challenge**: Reach 1024 or 2048 under time pressure with dynamic bonus time awarded for high-value merges (64+).
- **Advanced Power-Ups**:
  - **Undo**: Revert the last 10 moves using a state-buffered history.
  - **Swap Tiles**: Strategic ability to select and swap any two tiles on the board.
- **Visual Excellence**:
  - **Snappy Animations**: 100ms slide and 200ms "pop" merge effects.
  - **Feedback Systems**: Screen shake on major merges, full-screen confetti celebrations, and floating bonus time indicators.
  - **Modern UI**: Large 100x100 controls and a clean, centered responsive board layout.
- **Customization**: 6 premium themes (Rhino Grey, Turtle Green, Rare Indigo, Sunset Orange, Oceanic Blue, Arctic White).
- **Persistence**: High scores and user settings are automatically saved via `SharedPreferences`.

## 🛠 Recent Modifications & Enhancements
- **Refined Header UI**: Removed the "2048" text title for a cleaner, minimal aesthetic.
- **Optimized Score Tracking**: Implemented persistent High Score tracking across all sessions.
- **Enhanced Visibility**: Increased the size and padding of "Score" and "Best" boxes for better readability.
- **Timer Repositioning**: Moved the Countdown Timer to a prominent, centered position directly above the game board.
- **Touch Sensitivity**: Optimized swipe detection for physical devices using displacement-based logic (40px threshold).
- **UI Stability**: Resolved null-safety issues in the dynamic timer coloring logic.

## 📦 Getting Started
1. **Clone the repo**
2. **Run `flutter pub get`**
3. **Run `flutter run`** (Ensure you are on the latest stable Flutter channel)
