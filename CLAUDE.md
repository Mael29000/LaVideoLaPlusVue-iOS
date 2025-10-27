# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LaVideoLaPlusVue is a SwiftUI-based iOS application that appears to be a game with score tracking functionality. The app uses modern SwiftUI patterns with NavigationStack and sheet-based navigation.

## Build and Run Commands

Claude code don't need try to build, run or test the project. The command won't work. Let the user handle that.

## Architecture

### Core Architecture Pattern
The app follows an MVVM architecture with these key components:

- **Models**: Data structures (`HighScore`)
- **ViewModels**: Observable objects that manage state (`HallOfFameViewModel`)
- **Services**: Data layer with mock implementations (`HallOfFameService`)
- **Views**: SwiftUI views organized by screens and components

### Navigation System
The app uses a centralized navigation system:

- `AppRouter`: ObservableObject that manages NavigationPath and sheet presentation
- `AppDestination`: Enum defining all possible navigation destinations (lobby, game, endGame, hallOfFame, enterName)
- Navigation is handled through `navigateTo()` and `presentSheet()` methods

### Key Architectural Patterns

1. **Environment Objects**: Router, NamespaceContainer, and ViewModels are passed as environment objects
2. **Service Layer**: Mock services simulate network operations with async delays
3. **Namespace-based Animations**: Uses `@Namespace` for shared element transitions
4. **Sheet-based Modals**: Hall of Fame and Enter Name are presented as sheets

### Directory Structure

```
LaVideoLaPlusVue/
├── Models/           # Data models
├── Services/         # Business logic and data services  
├── ViewModels/       # MVVM view models
└── Views/
    ├── Components/   # Reusable UI components
    │   ├── Navigation/   # Navigation-related components
    │   ├── Onboarding/   # Onboarding flow components
    │   └── Utils/        # Utility views and modifiers
    └── Screens/      # Full-screen views
```

## Development Notes

### Target Configuration
- iOS 18.4+ deployment target
- Swift 5.0
- Uses SwiftUI previews for development

### State Management
- ViewModels use `@Published` properties for reactive updates
- Services use completion handlers with Result types
- Navigation state is centralized in AppRouter

### UI Patterns
- Custom navigation headers with `summitNavigationHeader` modifier
- Utility views for common UI patterns (shimmer effects, rounded corners, etc.)
- Color scheme uses custom colors defined in Assets.xcassets

### Testing Strategy
The project currently uses mock services that simulate network delays, making it easy to test loading states and error handling during development.
