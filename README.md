# Ryse Two - Professional Expense Management System

A comprehensive Flutter application designed for IT startup co-founders to manage shared expenses, track contributions, calculate settlements, and monitor spending patterns with real-time analytics, professional reporting, and **real-time push notifications**.

## Overview

Ryse Two automates the complex process of expense splitting between multiple co-founders with support for both personal and company fund expenses. The system intelligently calculates individual balances, identifies settlement requirements, and provides detailed financial analytics for informed decision-making. **All data changes are instantly notified to all team members via push notifications, even when the app is closed.**

## Core Features

### Expense Management
- Record expenses with detailed descriptions and categorization
- Distinguish between personal and company fund expenses
- Smart automatic equal splitting among specified contributors
- Support for 10 predefined expense categories
- Receipt attachment and notes for accountability
- Date tracking with comprehensive transaction history

### Co-founder Management
- Create and manage team member profiles
- Store unique financial identifiers for each team member
- Customize avatar colors for visual identification
- Track roles and designations within the startup
- Store bank account details (bank name, account number, IFSC code)
- Set individual contribution targets for financial planning

### Settlement & Accounting
- Automatic real-time balance calculation
- Intelligent settlement requirement identification
- Record payment settlements with notes
- Settlement status tracking and history
- Prevention of double-counting in settlements

### Advanced Analytics & Reporting
- Dashboard overview with key financial metrics
- Total expense amount tracking
- Company fund vs personal expense breakdown
- Per-capita expense analysis
- Contribution analysis by team member
- Expense category breakdown with percentages
- Visual charts and progress indicators for all metrics

### User Interface
- Material Design 3 professional appearance
- Intuitive bottom navigation with five main sections
- Responsive layout for mobile and tablet devices
- Modern visual hierarchy and spacing
- Professional typography using Google Fonts
- Color-coded visualizations for quick insights

### 🔔 Real-Time Push Notifications (NEW!)
- Instant notifications for all data changes
- Works even when app is closed
- Expense updates (add, edit, delete)
- Cofounder updates (add, edit, remove)
- Settlement recordings
- Company fund changes
- Professional notification UI with sound and vibration
- Powered by Firebase Cloud Messaging API V1 (OAuth 2.0)
- Secure service account authentication
- No backend server required - uses Firebase + MongoDB only

## Technical Architecture

### Framework & Stack
- Flutter 3.9.2+ for cross-platform development
- Dart programming language
- Provider pattern for state management with ChangeNotifier
- SQLite database via sqflite for persistent local storage
- FL Charts library for professional data visualization
- Material Design 3 components
- Google Fonts for typography
- Intl package for internationalization and date handling

### Project Structure

```
lib/
├── main.dart                          # Application entry point
├── models/                            # Data models with serialization
│   ├── cofounder.dart                # Team member profiles with financial data
│   ├── expense.dart                  # Transaction records with company fund tracking
│   └── settlement.dart               # Account settlements
├── database/                         # Data persistence layer
│   └── database_helper.dart          # SQLite CRUD operations
├── providers/                        # State management
│   └── expense_provider.dart         # Central app state with ChangeNotifier
├── theme/                            # UI styling and branding
│   └── app_theme.dart                # Material Design 3 theme with colors and typography
├── constants/                        # Application constants
│   └── app_constants.dart            # Expense categories and static values
└── screens/                          # User interface screens
    └── home/
        ├── home_screen.dart          # Main dashboard with overview
        ├── expense_screen.dart       # Expense list and management
        ├── cofounder_screen.dart     # Team member management
        ├── reports_screen.dart       # Three-tab analytics dashboard
        ├── settlements_screen.dart   # Settlement tracking interface
        ├── add_expense_dialog.dart   # Expense recording form
        └── add_cofounder_dialog.dart # Team member creation form

assets/
├── skyryse.jpg                       # Company logo used throughout app
└── logo.svg                          # Vector logo for scalable displays
```

### Architecture Pattern

The application follows MVVM (Model-View-ViewModel) architecture with Provider pattern:

- **Models** - Define data structures (CoFounder, Expense, Settlement) with complete serialization/deserialization
- **Database** - DatabaseHelper singleton manages all SQLite operations
- **State Management** - ExpenseProvider uses ChangeNotifier for reactive updates
- **Views** - Flutter screens build UI based on provider state
- **Theme** - Centralized Material Design 3 styling

## Data Models

### CoFounder
- Unique identifier (UUID)
- Name, email, phone number
- Role/designation within startup
- Bank account details (bank name, account number, IFSC code)
- Target contribution amount for financial planning
- Avatar color for visual identification
- Creation timestamp
- Active status flag

### Expense
- Unique identifier (UUID)
- Description and detailed notes
- Amount and currency
- Category from predefined list
- Payer (CoFounder who paid)
- Contributors list (team members to split with)
- Company fund flag (true for company expenses, false for personal)
- Company name if company fund expense
- Date of transaction
- Optional receipt attachment
- Creation timestamp

### Settlement
- Unique identifier (UUID)
- From (debtor) CoFounder
- To (creditor) CoFounder
- Amount to settle
- Date of settlement
- Notes for reference
- Settlement status (pending/completed)

## Database Schema

```sql
CREATE TABLE cofounder (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  phone TEXT,
  role TEXT,
  avatarColor TEXT,
  bankName TEXT,
  bankAccountNumber TEXT,
  bankIFSC TEXT,
  targetContribution REAL,
  createdAt TEXT,
  isActive INTEGER DEFAULT 1
);

CREATE TABLE expense (
  id TEXT PRIMARY KEY,
  description TEXT NOT NULL,
  category TEXT NOT NULL,
  amount REAL NOT NULL,
  paidById TEXT NOT NULL,
  contributorIds TEXT NOT NULL,
  isCompanyFund INTEGER DEFAULT 0,
  companyName TEXT,
  date TEXT NOT NULL,
  notes TEXT,
  receipt TEXT,
  createdAt TEXT,
  FOREIGN KEY (paidById) REFERENCES cofounder(id)
);

CREATE TABLE settlement (
  id TEXT PRIMARY KEY,
  fromId TEXT NOT NULL,
  toId TEXT NOT NULL,
  amount REAL NOT NULL,
  date TEXT NOT NULL,
  notes TEXT,
  settled INTEGER DEFAULT 0,
  FOREIGN KEY (fromId) REFERENCES cofounder(id),
  FOREIGN KEY (toId) REFERENCES cofounder(id)
);
```

## Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK (included with Flutter)
- Android SDK 21+ or Xcode 12.0+ for mobile deployment
- For Windows/Linux: appropriate development tools

### Installation & Setup

1. Clone the repository
```bash
git clone <repository-url>
cd ryse_two
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the application
```bash
flutter run
```

### Building for Production

**Android APK (Release)**
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

**Android App Bundle**
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

**iOS App**
```bash
flutter build ios --release
```

**Web Application**
```bash
flutter build web --release
```
Output: `build/web/`

**Windows Application**
```bash
flutter build windows --release
```

**Linux Application**
```bash
flutter build linux --release
```

**macOS Application**
```bash
flutter build macos --release
```

## Application Navigation

The app uses bottom navigation with five main sections:

1. **Dashboard** - Overview with key metrics and recent activity
   - Total expenses display
   - Company fund vs personal breakdown
   - Real-time team member balances
   - Team size and transaction counts

2. **Expenses** - Transaction management interface
   - Complete list of all expenses
   - Category-based filtering
   - Company fund indicator
   - Edit/delete capabilities
   - Add new expense dialog

3. **Co-founders** - Team member management
   - View all team members with profiles
   - Display roles and designations
   - Visual identification via avatar colors
   - Quick access to bank details
   - Add new team member dialog

4. **Reports** - Three-tab analytics dashboard
   - Overview tab: Key metrics with charts
   - By Person tab: Individual contributions and balances
   - By Category tab: Spending breakdown by category
   - Professional visualizations with pie and bar charts

5. **Settlements** - Account settlement tracking
   - Identify required settlements
   - Record completed payments
   - Settlement history with dates
   - Payment status tracking

## Workflow Example

1. Add co-founders to establish the team
2. Record expenses as they occur
3. Specify who paid and who benefits from the expense
4. System automatically calculates individual balances
5. View settlement requirements in Settlements tab
6. Record payments when transfers occur
7. Monitor spending trends in Reports section

## Balance Calculation Algorithm

The system calculates individual balances using the following algorithm:

```
For each expense:
  1. Identify payer and all contributors
  2. Calculate per-person share: amount / contributor_count
  3. Update payer balance: +amount (money received)
  4. Update each contributor balance: -share (money owed)
  5. Apply company fund flag appropriately

Final balance interpretation:
  Positive: Team member should receive refund
  Negative: Team member owes money to settle debts
  Zero: Fully settled
```

## Expense Categories

- Office Supplies - Stationery, equipment, furniture
- Equipment - Hardware, machinery, devices
- Software & Tools - Licenses, subscriptions, software
- Marketing - Advertising, branding, promotions
- Travel - Flights, hotels, transportation
- Utilities - Internet, electricity, phone
- Rent/Space - Office rent, workspace fees
- Food & Beverage - Meals, catering, refreshments
- Professional Services - Consulting, legal, accounting
- Other - Miscellaneous expenses

## Performance Optimization

- Efficient ListView.builder for large transaction lists
- Lazy loading on screen navigation
- Optimized database queries with proper indexing
- Minimal widget rebuilds through Provider architecture
- Asynchronous database operations prevent UI blocking
- Smart caching of calculated balances

## Data Persistence

All application data is stored locally in SQLite database:
- **Android**: `/data/data/com.skyryse.ryse_two/databases/ryse_two.db`
- **iOS**: Application Documents folder
- **Web**: Browser IndexedDB
- **Windows/Linux/macOS**: Application data directory

To backup data, backup the device or application directory. No cloud synchronization exists in the current version.

## Known Limitations

- Single database instance (no multi-company support)
- Local data only (no cloud synchronization)
- No multi-user authentication
- No recurring expense templates
- No budget tracking or spending alerts
- No receipt image storage in current version
- Single team setup per installation

## Future Enhancements

- Cloud synchronization with Firebase
- User authentication across devices
- Multi-company support for diversified portfolios
- Recurring expense automation
- Advanced budget tracking and alerts
- Trend analysis and forecasting
- Expense categorization AI
- Receipt image OCR processing
- Export functionality (PDF, CSV, Excel)
- Web dashboard interface
- Mobile app store deployment
- Expense approval workflows
- Payment gateway integration

## Configuration

### Application Settings
- Expense categories: `lib/constants/app_constants.dart`
- Color scheme: `lib/theme/app_theme.dart`
- Database name: DatabaseHelper.databaseName
- Avatar colors: AddCoFounderDialog._avatarColors

### Build Configuration
- App name: ryse_two (pubspec.yaml)
- App version: 1.0.0+1
- Minimum Android SDK: 21 (API Level 21)
- Target Android SDK: 33+
- iOS minimum deployment: 11.0

## Troubleshooting

**Database errors on startup:**
- Delete app and reinstall to reset database
- Check SQLite version compatibility with sqflite

**Icon not updating on Android:**
- Clean build: `flutter clean && flutter pub get`
- Rebuild app to apply new icons from flutter_launcher_icons

**UI performance issues:**
- Reduce number of historical transactions displayed
- Check device storage space
- Review app permissions (Storage, Calendar, etc.)

**Provider state not updating:**
- Ensure ExpenseProvider is properly initialized in main.dart
- Check Consumer widgets are properly wrapped around state-dependent UI

## 🔔 Push Notifications Setup

This app includes real-time push notifications for all data changes. To enable notifications:

### Quick Setup (5 minutes)
1. Create Firebase project and add Android app
2. Download `google-services.json` → place in `android/app/`
3. Generate Service Account credentials from Firebase Console
4. Create `.env` file with:
   ```env
   FCM_PROJECT_ID=your-project-id
   FCM_PRIVATE_KEY=your-private-key
   FCM_CLIENT_EMAIL=your-client-email
   ```
5. Run `flutter pub get` and launch app

### Detailed Documentation
- 📖 **Full Setup Guide**: [FIREBASE_SETUP.md](FIREBASE_SETUP.md)
- Uses **FCM API V1** with OAuth 2.0 authentication

### What Gets Notified?
- ✅ Expenses (add, update, delete)
- ✅ Cofounders (add, update, delete)  
- ✅ Company Funds (add, deduct)
- ✅ Settlements (record)

**Notifications work even when app is closed!** 🎯

## Version History

**v1.1.0** (Current - December 2025)
- ⭐ **NEW**: Real-time push notifications via Firebase FCM API V1
- ⭐ **NEW**: OAuth 2.0 authentication with service accounts
- ⭐ **NEW**: Background/foreground notification support
- ⭐ **NEW**: MongoDB-based device token management
- ⭐ **NEW**: Professional notification UI with sound & vibration
- Full expense tracking system
- Multi-member settlement calculations
- Advanced analytics and reporting
- Professional UI with Material Design 3
- MongoDB persistence layer
- Company fund tracking capability
- Co-founder profile management with financial details
- Cross-platform support (Android, iOS, Web, Windows, Linux, macOS)

**v1.0.0** (Initial Release)
- Basic expense tracking and settlement system
- SQLite persistence (migrated to MongoDB in v1.1.0)

## License

Proprietary software for Skyryse IT startup internal use only.

## Support

For issues, feature requests, or improvements, contact the development team.

---

**Application:** Ryse Two
**Version:** 1.0.0
**Last Updated:** November 2025
**Platform Support:** Android, iOS, Web, Windows, Linux, macOS
**Status:** Production Ready
