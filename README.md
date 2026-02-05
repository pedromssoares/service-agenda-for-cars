# Service Agenda for Cars

An iOS offline-first car maintenance app for logging services, tracking reminders, and managing vehicle maintenance history.

## Requirements

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

## Project Structure

```
ServiceAgendaForCars/
├── App/                    # App entry point and main views
├── Models/                 # SwiftData models
├── Services/              # Business logic layer
│   ├── Persistence/       # Data persistence
│   ├── Notifications/     # Local notifications
│   └── Export/            # CSV export
├── Features/              # Feature modules
│   ├── UpNext/           # Upcoming services view
│   ├── History/          # Service history
│   ├── AddService/       # Add service flow
│   └── Settings/         # App settings
└── Shared/               # Shared utilities
    ├── Formatting/       # Formatters
    └── Components/       # Reusable UI components
```

## Getting Started

1. Open `ServiceAgendaForCars.xcodeproj` in Xcode
2. Select a simulator or device (iPhone 15 or later recommended)
3. Build and run (Cmd+R)

## Features (V1)

- 100% offline (no backend, no sync)
- Log car services with date, odometer, cost, and notes
- View upcoming/overdue maintenance
- Local push notifications for reminders
- CSV export of service history
- Support for both kilometers and miles

## Development

See [CLAUDE.md](CLAUDE.md) for detailed development guidelines and architecture decisions.
