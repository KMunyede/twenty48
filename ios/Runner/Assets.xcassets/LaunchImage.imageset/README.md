# My2048 - iOS Launch Screen & Project Overview

This directory contains the launch screen assets for the iOS version of the My2048 game.

## 🚀 Game Features
- **Dual Game Modes**: 
  - **Standard 2048**: Classic grid-merging gameplay.
  - **Timer Challenge**: Reach 1024 or 2048 under time pressure with dynamic bonus time awarded for high-value merges (64+).
- **Advanced Power-Ups**:
  - **Undo**: Revert the last 10 moves using a state-buffered history.
  - **Swap Tiles**: Select and swap any two tiles on the board for strategic positioning.
- **Visual Excellence**:
  - **Snappy Animations**: 100ms slide and 200ms "pop" merge effects.
  - **Feedback Systems**: Screen shake on major merges, full-screen confetti celebrations, and floating bonus time indicators.
  - **Modern UI**: Large 100x100 controls and a clean, responsive board layout.
- **Customization**: 6 premium themes (Rhino Grey, Turtle Green, Rare Indigo, Sunset Orange, Oceanic Blue, Arctic White).
- **Persistence**: High scores and user settings are automatically saved via `SharedPreferences`.

## 🛠 Recent Modifications & Enhancements
- **Refined Header UI**: Removed the "2048" text title to provide a cleaner, minimal aesthetic.
- **Optimized Score Tracking**: Implemented persistent High Score tracking across all sessions.
- **Enhanced Visibility**: Increased the size and padding of "Score" and "Best" boxes for better readability in both game modes.
- **Timer Repositioning**: Moved the Countdown Timer to a prominent, centered position directly above the game board in Time Challenge Mode.
- **UI Stability**: Resolved null-safety issues in the dynamic timer coloring logic (Color.lerp fixes).
- **Layout Balancing**: Adjusted spacing and font scales to ensure a premium feel across various screen sizes.
