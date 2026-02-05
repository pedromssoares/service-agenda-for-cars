# Changelog

All notable changes to Service Agenda for Cars will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-05

### Added
- Vehicle management (add, edit, delete vehicles)
- Service logging with date, odometer, cost, and notes
- Service history view with chronological list
- Up Next view showing overdue/due soon/upcoming services
- Smart reminder calculation based on date and odometer intervals
- Local push notifications (max 40, auto re-scheduled)
- CSV export of complete service history
- Kilometers and miles support (stored in km, displayed per vehicle preference)
- Unit conversion at UI layer
- Onboarding flow for first-time users
- 8 default service type templates (Oil Change, Tire Rotation, etc.)
- Current odometer tracking per vehicle
- Update odometer quick action
- App icon

### Technical
- iOS 17+ minimum deployment target
- SwiftUI for all UI components
- SwiftData for local persistence
- MVVM architecture
- Zero third-party dependencies
- 100% offline operation
- Automatic notification re-scheduling on app launch/foreground

### Database Schema
- Vehicle: id, name, unitPreference, currentOdometerKm, createdAt
- ServiceTypeTemplate: id, name, defaultIntervalDays, defaultIntervalDistanceKm, isEnabled
- ServiceEvent: id, vehicleId, serviceTypeId, date, odometerKm, cost, notes
- ReminderRule: id, serviceTypeId, enabled, daysInterval, distanceIntervalKm

### Files
- 35 files
- 3,159 lines of code
- Clean folder structure following MVVM pattern
