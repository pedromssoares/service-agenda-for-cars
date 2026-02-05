# Service Agenda for Cars

A beautiful, offline-first iOS app for tracking your car's maintenance history and never missing a service. Built with SwiftUI and SwiftData.

<div align="center">

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Xcode](https://img.shields.io/badge/Xcode-15.0+-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

</div>

## Features

### Core Features
- **📱 100% Offline** - No backend, no sync, no internet required
- **🚗 Multi-Vehicle Support** - Track maintenance for all your vehicles
- **📝 Service Logging** - Record date, odometer, cost, notes, and photos
- **⏰ Smart Reminders** - Date and distance-based notifications
- **📊 Cost Analytics** - Visualize spending with interactive charts
- **📤 CSV Export** - Export complete service history
- **🌍 Dual Units** - Support for kilometers and miles
- **🌙 Dark Mode** - Beautiful UI in light and dark themes

### V2 Enhanced Features
- **✏️ Edit/Delete Services** - Full control over service records
- **📸 Service Photos** - Attach up to 5 photos per service
- **🔧 Custom Service Types** - Create custom maintenance categories
- **🎯 Vehicle-Specific Reminders** - Override intervals per vehicle
- **📈 Cost Analytics Dashboard** - Interactive charts with trends
- **🏠 Home Screen Widgets** - See next service at a glance (requires setup)
- **🔒 Lock Screen Widgets** - Quick access from lock screen

## Screenshots

[Add screenshots here when ready]

## Requirements

- **iOS**: 17.0 or later
- **Xcode**: 15.0 or later
- **Swift**: 5.9 or later
- **Device**: iPhone or iPad

## Installation

### Option 1: Xcode
1. Clone this repository
   ```bash
   git clone https://github.com/yourusername/service-agenda-for-cars.git
   cd service-agenda-for-cars
   ```
2. Open `ServiceAgendaForCars.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run (⌘R)

### Option 2: TestFlight
[Coming soon]

### Option 3: App Store
[Coming soon]

## Getting Started

### First Launch
1. **Welcome Screen** - Enter your first vehicle name and current odometer
2. **Service History** - Optionally enter past service records for accurate reminders
3. **Notification Permission** - Grant permission for maintenance reminders

### Daily Use
- **Up Next** - View overdue, due soon, and upcoming services
- **Add Service** - Quick logging when you get service done
- **History** - Browse all past services with photos
- **Settings** - Manage vehicles, service types, and reminders

## Project Structure

```
ServiceAgendaForCars/
├── App/                        # App entry point and onboarding
│   ├── ServiceAgendaForCarsApp.swift
│   ├── ContentView.swift
│   └── OnboardingView.swift
├── Models/                     # SwiftData models
│   ├── Vehicle.swift
│   ├── ServiceEvent.swift
│   ├── ServiceTypeTemplate.swift
│   └── ReminderRule.swift
├── Services/                   # Business logic layer
│   ├── Persistence/
│   │   └── DataSeeder.swift
│   ├── Notifications/
│   │   └── NotificationManager.swift
│   ├── Export/
│   │   ├── CSVExporter.swift
│   │   └── CSVDocument.swift
│   └── ReminderCalculator.swift
├── Features/                   # Feature modules
│   ├── UpNext/
│   │   ├── UpNextView.swift
│   │   └── UpdateOdometerView.swift
│   ├── History/
│   │   ├── HistoryView.swift
│   │   └── EditServiceView.swift
│   ├── AddService/
│   │   └── AddServiceView.swift
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   ├── AddVehicleView.swift
│   │   ├── EditVehicleView.swift
│   │   ├── ManageServiceTypesView.swift
│   │   ├── CreateServiceTypeView.swift
│   │   ├── EditServiceTypeView.swift
│   │   └── VehicleRemindersView.swift
│   └── Analytics/
│       └── CostAnalyticsView.swift
├── Shared/                     # Shared utilities
│   ├── Formatting/
│   │   ├── DistanceFormatter.swift
│   │   └── CurrencyFormatter.swift
│   ├── Components/
│   │   ├── PhotoPicker.swift
│   │   └── PhotoViewer.swift
│   └── Themes/
│       └── ColorTheme.swift
├── ServiceAgendaWidget/        # Widget extension
│   ├── ServiceAgendaWidget.swift
│   └── ServiceAgendaWidgetBundle.swift
└── ServiceAgendaForCarsTests/  # Unit tests
    ├── Models/
    ├── Services/
    └── Utilities/
```

## Architecture

### Design Pattern
- **MVVM** - Views, Models, and Service layer separation
- **Offline-First** - All data stored locally with SwiftData
- **No Dependencies** - Zero third-party frameworks

### Data Flow
1. **SwiftData** - Local persistence with relationships
2. **ReminderCalculator** - Business logic for service calculations
3. **NotificationManager** - iOS local notifications (max 40)
4. **Unit Conversion** - Store in km, display per preference

### Key Design Decisions
- Store odometer in kilometers, convert at UI layer
- Maximum 40 notifications due to iOS limit
- Photos stored as JPEG data (70% compression)
- Vehicle-specific rules override default intervals
- CSV uses ISO8601 dates for consistency

## Testing

### Run Tests
```bash
# In Xcode
⌘U

# Or command line
xcodebuild test \
  -scheme ServiceAgendaForCars \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Test Coverage
- **80+ test cases** covering:
  - Distance unit conversion (km ↔ miles)
  - Currency formatting
  - Service reminder calculations
  - CSV export with special character escaping
  - Model initialization and validation
  - Photo management (up to 5 per service)

See [ServiceAgendaForCarsTests/README.md](ServiceAgendaForCarsTests/README.md) for details.

## Widget Setup

Widgets require manual Xcode configuration. See [WIDGET_SETUP.md](WIDGET_SETUP.md) for step-by-step instructions.

**Widget Types:**
- Small: Shows next service with countdown
- Medium: Shows service details with vehicle name
- Circular (Lock Screen): Days until next service
- Rectangular (Lock Screen): Service name and countdown

## Development

### Adding a New Feature
1. Create feature folder under `Features/`
2. Add views, view models (if needed)
3. Update navigation in `ContentView.swift`
4. Add tests in `ServiceAgendaForCarsTests/`
5. Update CHANGELOG.md

### Database Schema Changes
SwiftData schema changes require app deletion:
1. Delete app from simulator/device
2. Clean build folder (⌘⇧K)
3. Build and run

### Coding Guidelines
- Follow existing MVVM structure
- Store distances in km, convert at UI
- Use `ColorTheme` for all colors (dark mode support)
- Add tests for business logic
- See [CLAUDE.md](CLAUDE.md) for detailed guidelines

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

### Latest: v2.0.0 (2026-02-05)
- Edit/delete service entries
- Service photos (up to 5 per service)
- Custom service types
- Vehicle-specific reminder customization
- Cost analytics with charts
- Dark mode support
- Home screen and lock screen widgets

### v1.0.0 (2026-02-05)
- Initial release
- Vehicle management
- Service logging and history
- Smart reminders (date and distance-based)
- Local notifications
- CSV export
- Kilometers and miles support

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for new functionality
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with SwiftUI and SwiftData
- Charts powered by Swift Charts
- Icons from SF Symbols
- Developed with assistance from Claude (Anthropic)

## Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/service-agenda-for-cars/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/service-agenda-for-cars/discussions)

## Roadmap

### Potential Future Features
- [ ] iCloud sync (optional)
- [ ] Apple Watch companion app
- [ ] Fuel tracking
- [ ] Expense categories
- [ ] Service reminders by engine hours
- [ ] Vehicle health scoring
- [ ] Maintenance schedule templates by car model
- [ ] Share service history as PDF

---

**Made with ❤️ for car enthusiasts who never want to miss an oil change**
