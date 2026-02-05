# V2 Development Plan

## Goals
Enhance V1 with advanced features while maintaining simplicity and offline-first approach.

## Features to Implement

### 1. Edit/Delete Service Entries ⬅️ START HERE
**Why first:** Users need to fix mistakes, foundational feature
- Edit existing service entries (date, odometer, cost, notes)
- Delete individual services
- Confirmation dialogs for destructive actions
- Update notifications after edits

**Files to modify:**
- HistoryView.swift (add edit navigation)
- New: EditServiceView.swift

**Estimated complexity:** Low
**Priority:** Critical

---

### 2. Service Photos
**Why next:** Natural extension of service logging
- Attach photos to service entries (1-5 photos per service)
- Photo picker integration
- Thumbnail display in history
- Full-screen photo viewer
- Photos stored locally (no cloud)
- Proper cleanup when service deleted

**Files to modify:**
- ServiceEvent model (add photos relationship)
- AddServiceView.swift (photo picker)
- EditServiceView.swift (photo management)
- HistoryView.swift (show thumbnails)
- New: PhotoPicker, PhotoViewer components

**Estimated complexity:** Medium
**Priority:** High

---

### 3. Custom Service Types
**Why next:** User flexibility for non-standard services
- Create custom service types
- Edit/delete custom types
- Mark as enabled/disabled
- Keep default templates
- Custom types per user (not per vehicle)

**Files to modify:**
- New: ManageServiceTypesView.swift
- SettingsView.swift (link to management)
- ServiceTypeTemplate model (add isCustom flag)

**Estimated complexity:** Low-Medium
**Priority:** High

---

### 4. Reminder Customization per Vehicle
**Why next:** Different vehicles have different maintenance schedules
- Override default intervals per vehicle
- Custom reminders (e.g., "Registration renewal")
- Enable/disable specific service reminders per vehicle
- Lead time preferences (notify X days/km before due)

**Files to modify:**
- New: VehicleRemindersView.swift
- ReminderRule model (add vehicleId relationship)
- ReminderCalculator.swift (check vehicle-specific rules first)
- EditVehicleView.swift (link to reminder settings)

**Estimated complexity:** Medium
**Priority:** Medium

---

### 5. Cost Tracking & Charts
**Why next:** Users want to see maintenance costs over time
- Total cost per vehicle
- Cost trends (monthly/yearly)
- Cost by service type
- Simple bar/line charts
- Average cost per service type
- Export cost summary

**Files to modify:**
- New: CostAnalyticsView.swift
- New: ChartView components (use Swift Charts)
- SettingsView or History (add analytics link)

**Estimated complexity:** Medium
**Priority:** Medium

---

### 6. Dark Mode Support
**Why next:** Polish & modern UX expectation
- Respect system appearance
- Custom colors that work in both modes
- Test all views in dark mode
- Update app icon for dark mode (if needed)
- Badge colors adjusted for dark mode

**Files to modify:**
- All views (color adjustments)
- New: ColorTheme.swift (centralized colors)

**Estimated complexity:** Low-Medium
**Priority:** Low (Polish)

---

### 7. Widget for Up Next
**Why last:** Advanced iOS feature, requires WidgetKit
- Home screen widget showing next due service
- Lock screen widget (circular progress)
- Update widget when services logged
- Widget deep links to app
- Multiple widget sizes (small, medium, large)

**Files to create:**
- New: ServiceAgendaWidget target
- New: WidgetViews.swift
- New: WidgetTimelineProvider.swift
- App Groups for data sharing

**Estimated complexity:** High
**Priority:** Low (Advanced feature)

---

## Implementation Order

1. ✅ **Edit/Delete Service Entries** (Day 1)
2. **Service Photos** (Day 2-3)
3. **Custom Service Types** (Day 3-4)
4. **Reminder Customization** (Day 4-5)
5. **Cost Tracking & Charts** (Day 5-6)
6. **Dark Mode Support** (Day 6-7)
7. **Widget** (Day 7-8)

## Technical Considerations

### Database Changes
- Add photos storage (file references or embedded data)
- Add custom service type flag
- Add vehicle-specific reminder rules
- Migration strategy from V1

### Performance
- Lazy loading for photos
- Efficient chart rendering
- Widget update optimization

### Testing Strategy
- Test data migration from V1
- Test with large datasets (100+ services)
- Test all edit/delete flows
- Test photo storage/cleanup
- Test widget updates

## Breaking Changes
None - V2 should be fully backward compatible with V1 data.

## Release Strategy
- Internal testing after each feature
- Beta TestFlight after feature 4
- Final release after feature 7
- Tag as v2.0.0
