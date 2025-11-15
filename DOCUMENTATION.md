# Documentation Guide

This document consolidates essential development and user documentation for Ryse Two.

## Quick Start

### Prerequisites
- Flutter SDK 3.9.2+
- Dart SDK
- Android SDK or Xcode

### Setup
```bash
flutter pub get
flutter run
```

### Build Release
```bash
flutter build apk --release
```

## Application Overview

Ryse Two is an expense management system designed for co-founders to track shared expenses, calculate individual contributions, and automatically determine settlement amounts.

### Core Workflow

1. Add team members with unique identifiers
2. Record expenses with payer and contributor information
3. System calculates real-time balances
4. View settlement requirements
5. Record account settlements
6. Monitor spending through analytics

### Navigation Structure

- Dashboard: Overview and key metrics
- Expenses: Transaction management
- Co-founders: Team member management
- Reports: Analytics with three views (overview, person, category)
- Settlements: Account settlement tracking

## Technical Architecture

### Stack
- Flutter (3.9.2+)
- Provider pattern state management
- SQLite local database
- Material Design 3 interface
- FL Charts for analytics

### Data Models

**CoFounder**: Team member profile
- Identifier, name, email, phone
- Avatar color for UI identification
- Creation timestamp, active status

**Expense**: Transaction record
- Description, amount, category
- Payer identifier
- List of contributors
- Date, notes, receipt reference

**Settlement**: Account settlement
- From and to identifiers
- Amount, date, status

### Database

Three SQLite tables manage persistence:
- cofounder: Profile data
- expense: Transaction history
- settlement: Settlement records

### State Management

ExpenseProvider implements business logic:
- Data loading and persistence
- Balance calculation
- CRUD operations
- UI state notifications

**Balance Algorithm**:
For each expense, add full amount to payer, divide by contributor count, subtract each contributor's share. Positive balance indicates refund owed; negative indicates amount due.

## Building Applications

### Platform Builds

**Android**
```bash
flutter build apk --release
```

**iOS**
```bash
flutter build ios --release
```

**Web**
```bash
flutter build web --release
```

**Windows/Linux/macOS**
```bash
flutter build windows --release
flutter build linux --release
flutter build macos --release
```

### Troubleshooting Build Issues

Clean build:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

Check device connection:
```bash
flutter devices
adb devices
```

Install to device:
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Features

### Expense Management
- Record with description, amount, category
- Automatic splitting among contributors
- 10 predefined categories
- Category-based filtering
- Receipt and note tracking

### Team Management
- Add member profiles
- Custom avatar colors
- Real-time balance tracking
- Contact information storage

### Analytics
- Total spending metrics
- Per-person contribution analysis
- Category-wise breakdown
- Visual charts and graphs

### Settlement
- Automatic balance calculation
- Settlement recording
- Payment requirement tracking
- History maintenance

## Performance Considerations

- ListView.builder for efficient list rendering
- Lazy data loading
- Provider pattern minimizes widget rebuilds
- Optimized database queries
- Async database operations

## Data Persistence

Data stored locally in SQLite:
- Android: Application databases directory
- iOS: Application Documents folder
- Web/Desktop: Application data directory

Device backup includes app data. No cloud synchronization in current version.

## Limitations

- Single database per installation
- No cloud synchronization
- No recurring expense automation
- No multi-user authentication
- No receipt image storage

## Planned Enhancements

- Cloud data synchronization
- User authentication
- Multi-device support
- Recurring expense automation
- Budget tracking
- Export functionality
- App store distribution
- Web dashboard

## Development Guidelines

### Code Organization
- Models: Data structures with serialization
- Database: Persistence layer
- Providers: State management
- Screens: UI implementation
- Theme: Design system

### Naming Conventions
- Files: snake_case.dart
- Classes: PascalCase
- Variables: camelCase
- Constants: CONSTANT_CASE

### Version Information
- Current: 1.0.0
- Release Date: November 2025
- Platforms: Android, iOS, Web, Windows, Linux, macOS

## Support

For technical assistance, consult source code documentation or contact development team.
