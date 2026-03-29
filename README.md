# My2048 - Advanced Flutter 2048 Game

A fully functional, cross-platform 2048 game built with Flutter, featuring smooth animations, responsive UI, and advanced gameplay mechanics.

## 🚀 Key Features

### 🎮 Gameplay Modes
*   **Standard Mode**: The classic 2048 experience.
*   **Timer Challenge (1024)**: Reach 1024 within 300 seconds.
*   **Timer Challenge (2048)**: Reach 2048 within 360 seconds.
*   **Dynamic Bonuses**: Merging high-value tiles (64 to 1024) grants bonus time (10s to 40s) in Challenge Mode.

### ⚡ Power-Ups
*   **Undo**: Revert your last 10 moves to fix mistakes.
*   **Swap Tiles**: A strategic power-up allowing you to swap any two tiles on the board.

### 🎨 Customization & UI
*   **Multiple Themes**: Choose from Rhino Grey, Turtle Green, Rare Indigo, Sunset Orange, Oceanic Blue, and Arctic White.
*   **Responsive Design**: Dynamically scales to fit any screen size (Mobile, Web, Desktop) while maintaining a perfect square grid.
*   **Centred Settings Menu**: A spacious, scrollable 390px wide menu with modern rounded corners.

### ✨ Visual Effects
*   **Celebration System**: Reaching 1024, 2048, 4096, or 8192 triggers a **screen shake** and a **7-second confetti drop**.
*   **Dynamic Timer**: The timer background changes color (Green -> Yellow -> Orange -> Red) and pulses as time runs out.
*   **Floating Feedback**: Earned bonus time floats and fades on the screen for immediate feedback.

### 💾 Persistence & Performance
*   **State Persistence**: Automatically remembers your last used Game Mode and Theme selection across sessions.
*   **Robust Input**: Supports both touch swipes and physical keyboard arrow keys with optimized focus management.

## 🛠 Tech Stack
*   **Framework**: Flutter
*   **State Management**: Provider (MultiProvider)
*   **Local Storage**: Shared Preferences
*   **Animations**: Built-in Flutter Animations + Confetti Package

## 🏁 Getting Started

1.  **Clone the repo**:
    ```bash
    git clone https://github.com/your-repo/twenty48.git
    ```
2.  **Install dependencies**:
    ```bash
    flutter pub get
    ```
3.  **Run the app**:
    ```bash
    flutter run
    ```

---
*Developed with ❤️ using Flutter.*
