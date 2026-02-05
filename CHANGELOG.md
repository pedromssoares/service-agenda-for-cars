# Changelog

All notable changes to Service Agenda for Cars will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-02-05

### Added - Enhanced Features
- **Edit/Delete Services**: Full editing capability for service entries with confirmation dialogs
- **Service Photos**: Attach up to 5 photos per service with thumbnail display and full-screen viewer
- **Custom Service Types**: Create, edit, and delete custom maintenance types beyond defaults
- **Vehicle-Specific Reminders**: Override default intervals per vehicle for personalized maintenance schedules
- **Cost Analytics**: Interactive charts showing cost trends, totals, and breakdowns by service type
- **Dark Mode Support**: Full support for system appearance with semantic color theming
- **Home Screen Widgets**: Small and medium widgets showing next due service with countdown
- **Lock Screen Widgets**: Circular and rectangular widgets for at-a-glance service tracking

### Enhanced
- All views updated with ColorTheme for consistent dark mode support
- Status badges now use semantic colors that adapt to light/dark mode
- Photo storage with JPEG compression (70% quality)
- Widget updates every hour with priority-based service display
- ReminderCalculator prioritizes vehicle-specific rules over defaults

### Technical
- WidgetKit extension with App Groups for data sharing
- Swift Charts integration for cost analytics
- PhotosUI integration for multi-photo picker
- Expanded SwiftData models with relationships and cascade delete
- App Groups configuration (group.com.serviceagenda.shared)

### Database Schema Changes
- ServiceEvent: Added photoData1-5 fields for photo storage
- ServiceTypeTemplate: Added isCustom flag to distinguish custom types
- ReminderRule: Added vehicle relationship for vehicle-specific rules
- Vehicle: Added reminderRules relationship

### New Files
- ServiceAgendaWidget/ServiceAgendaWidget.swift (main widget)
- ServiceAgendaWidget/ServiceAgendaWidgetBundle.swift
- Features/History/EditServiceView.swift
- Features/Settings/ManageServiceTypesView.swift
- Features/Settings/CreateServiceTypeView.swift
- Features/Settings/EditServiceTypeView.swift
- Features/Settings/VehicleRemindersView.swift
- Features/Analytics/CostAnalyticsView.swift
- Shared/Components/PhotoPicker.swift
- Shared/Components/PhotoViewer.swift
- Shared/Themes/ColorTheme.swift
- WIDGET_SETUP.md (manual configuration guide)

### Breaking Changes
- Database schema changes require app reinstall (SwiftData limitation)
- All V1 data remains compatible after reinstall

---

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
