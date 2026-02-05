# CLAUDE.md

This file configures Claude Code for this repository.
Keep it concise, practical, and aligned with how we actually build this app.

## App goal
Build an iOS **offline-first** car maintenance app:

- App Store Name: "Service Agenda for Cars"
- Subtitle: "Maintenance reminders & log"

Core value: log car services quickly, see what's due next, and get reminders by date and/or odometer.
Must include CSV export of service history.

## Non-negotiable V1 constraints
- 100% local: no accounts, no backend, no sync, no networking.
- Cars only in V1 (motorcycles/other vehicles are future improvements).
- Support odometer in **kilometers and miles** in V1:
  - Store odometer internally in ONE base unit.
  - Convert only at the UI layer based on user preference.
- Local notifications:
  - Schedule at most 40 pending notifications at any time.
  - Re-schedule when the app launches / returns to foreground.
- CSV export:
  - Use SwiftUI `FileDocument` + `fileExporter`.
- Avoid over-engineering: ship a small, reliable V1.

## Tech stack & decisions
- iOS 17+
- SwiftUI
- SwiftData for local persistence.
- Simple MVVM (Views + ViewModels + Services).
- No third-party dependencies in V1 unless explicitly requested.

## Suggested project structure
- App/
  - ServiceAgendaForCarsApp.swift
- Models/               (SwiftData models)
- Services/
  - Persistence/
  - Notifications/
  - Export/
- Features/
  - UpNext/
  - History/
  - AddService/
  - Settings/
- Shared/
  - Formatting/
  - Components/

## Minimum data model (SwiftData)
Create SwiftData models (names can be adjusted for clarity):
- Vehicle: id, name, unitPreference, createdAt
- ServiceTypeTemplate: id, name, defaultIntervalDays, defaultIntervalDistanceBase, isEnabled
- ServiceEvent: id, vehicleId, serviceTypeId, date, odometerBase, cost (optional), notes (optional)
- ReminderRule: id, serviceTypeId, enabled, daysInterval (optional), distanceIntervalBase (optional)

Seed initial templates on first launch.

## UX priorities
- Time-to-value: user creates 1 service log entry + 1 reminder in < 60 seconds.
- "Quick add" path: logging a service should be minimal taps.
- "Up Next" should clearly show:
  - next due services
  - overdue services

## CSV export format
CSV must be UTF-8 with a fixed header row and comma separator.
Fields:

vehicleName, serviceType, dateISO, odometerDisplayed, odometerUnit, cost, notes

## Working agreement (how Claude should operate)
- Propose a short plan before large changes.
- Make incremental changes; prefer small, reviewable commits.
- Ask clarifying questions if requirements are ambiguous.
- Do not add out-of-scope features for V1.
- Do not delete files/code without explicit confirmation.

## Quality checklist (before each PR)
- Builds on Simulator (e.g., iPhone 15/16).
- Main flows work: Add Service → Up Next → History → Export CSV.
- Switching units (km/mi) never corrupts history.
- Notifications never exceed 40 pending scheduled.
- No network calls.
