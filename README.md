# ClueoGames

A SwiftUI iOS app featuring a fresh set of daily puzzles: Sudoku, Unscramble, and Exacto.

## Highlights

- Three daily puzzle modes with multiple difficulty levels
- Deterministic puzzle generation for a consistent daily experience
- Completion tracking and daily reminders
- Light, dark, and system appearance options
- Optional ClueoGames+ subscription for ad-free play and past-puzzle access

## Tech stack

- Swift and SwiftUI
- MVVM-style organization (`Models`, `ViewModels`, `Views`, and `Services`)
- Swift Package Manager
- RevenueCat for subscription management
- StoreKit configuration for local purchase testing

## Getting started

### Requirements

- Xcode 15 or later
- iOS 17.6 or later

### Run locally

1. Clone the repository.
2. Open `CluoGames.xcodeproj` in Xcode.
3. Let Xcode resolve Swift Package Manager dependencies.
4. Select an iOS simulator or device and press **Run**.

## Project structure

```text
CluoGames/
├── Models/       # Puzzle and game-state models
├── Services/     # Puzzle generation, purchases, notifications, and haptics
├── ViewModels/   # Presentation and game logic
├── Views/        # SwiftUI screens and components
└── Resources/    # App data model and app resources
```

## Puzzle modes

| Mode | Description |
| --- | --- |
| Sudoku | Complete a 9×9 grid without repeating digits in a row, column, or box. |
| Unscramble | Solve the daily word by rearranging its letters. |
| Exacto | Use the supplied numbers and multiplication to match a target. |

## License

Copyright © 2026 Maicol Cabreja. All rights reserved. This repository is provided for portfolio and evaluation purposes only. No permission is granted to copy, modify, distribute, or use its code or assets without prior written permission.
