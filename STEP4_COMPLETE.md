# Step 4 Complete: Local Notifications

## What was implemented

### 1. NotificationManager Service
**File:** `ServiceAgendaForCars/Services/Notifications/NotificationManager.swift`

**Features:**
- Singleton service managing all notification operations
- Requests notification permissions on first launch
- Schedules up to 40 notifications (iOS limit)
- Smart prioritization: most urgent services first
- Re-schedules notifications automatically

**Notification Logic:**
- **Overdue services**: Fire immediately (5 seconds for testing)
- **Due services**: Fire at 9 AM on the due date
- **Distance-only reminders**: Fire if within 500 km
- Only schedules notifications for services that are:
  - Overdue
  - Due soon
  - Upcoming within 60 days or 2000 km

**Notification Content:**
- Title: "Service Due: [Service Name]"
- Body: Vehicle name • Status/timing details
- Example: "Honda Civic • Due in 15 days or in 3000 km"

### 2. App Integration
**File:** `ServiceAgendaForCars/App/ServiceAgendaForCarsApp.swift`

**Auto Re-scheduling:**
- Monitors app lifecycle with `scenePhase`
- When app becomes active (launch or foreground):
  - Fetches current data
  - Recalculates due services
  - Re-schedules notifications
- Ensures notifications stay current with latest data

### 3. Onboarding Permission Request
**File:** `ServiceAgendaForCars/App/OnboardingView.swift`
- Requests notification permission after user adds first vehicle
- Happens automatically on first setup
- Non-blocking if user denies

### 4. Settings Integration
**File:** `ServiceAgendaForCars/Features/Settings/SettingsView.swift`

**New Notifications Section:**
- Shows permission status (Enabled/Disabled with icons)
- Displays count of pending notifications
- "Enable in System Settings" button if disabled (deep links to Settings app)
- Updates in real-time

### 5. Up Next Integration
**File:** `ServiceAgendaForCars/Features/UpNext/UpNextView.swift`
- Automatically schedules notifications when view appears
- Re-schedules when due services change
- Silent background operation

## How it works

### Notification Priority (40-notification limit):
1. All due services calculated
2. Filter to relevant services (overdue, due soon, upcoming within limits)
3. Sort by urgency
4. Take top 40
5. Schedule with appropriate timing

### Auto Re-scheduling Triggers:
- App launch
- App returns to foreground
- Service logged
- Odometer updated
- Due services recalculated

### Permission Handling:
- First launch: Requests permission after vehicle setup
- Denied: Shows option in Settings to enable
- Granted: Notifications work automatically

## How to test

### 1. First-time setup (Fresh install):
1. **Delete app** from simulator
2. **Clean build** (Cmd+Shift+K)
3. **Build and run** (Cmd+R)
4. **Complete onboarding:**
   - Add vehicle
   - Tap "Get Started"
   - **Allow Notifications** when prompted

### 2. Verify notification permission:
1. Go to **Settings tab**
2. Check "Notifications" section
3. Should show:
   - Status: ✓ Enabled (green)
   - Pending Reminders: [number]

### 3. Test notification scheduling:
1. **Add a service 200 days ago:**
   - History → "+"
   - Oil Change
   - Date: 200 days ago
   - Odometer: 40000
   - Save

2. **Set current odometer to trigger distance overdue:**
   - Settings → vehicle → set to 50000
   - (Interval is 8000, so 40000 + 8000 = 48000 due, 50000 current = overdue)

3. **Check Up Next tab:**
   - Should show Oil Change as OVERDUE

4. **Wait 10 seconds:**
   - Should receive notification: "Service Due: Oil Change"
   - Body: "Honda Civic • Overdue since [date]"

### 4. Test notification permissions denied:
1. **Deny permission:**
   - Delete app
   - Reinstall
   - When prompted for notifications → **Don't Allow**

2. **Check Settings:**
   - Status: ✗ Disabled (red)
   - Button: "Enable in System Settings"
   - Tap button → Opens iOS Settings

3. **Enable manually:**
   - iOS Settings → Service Agenda for Cars → Notifications → ON
   - Return to app
   - Settings should update to "Enabled"

### 5. Test re-scheduling:
1. **Add service** while app is open
2. **Background the app** (swipe up to home)
3. **Wait a few seconds**
4. **Return to app** (tap icon)
5. Notifications should be re-scheduled automatically

### 6. Verify 40-notification limit:
1. **Add multiple vehicles**
2. **Check Settings → Pending Reminders**
3. Should never exceed 40

## Important notes

### Notification timing for testing:
- **Overdue services**: 5 seconds (for easy testing)
- **Production**: Should increase to more reasonable timing
- Edit `NotificationManager.swift` line with `timeInterval: 5` to adjust

### iOS Simulator notifications:
- Work exactly like real device
- Appear as banners at top
- Visible in Notification Center (swipe down from top)

### Permission best practices:
- Requested after user adds vehicle (context established)
- Non-blocking if denied
- Easy to enable later via Settings

### Real-time updates:
- All views observe `notificationManager` via `@EnvironmentObject`
- Status updates automatically when permissions change
- Count updates when notifications scheduled

## Next steps

Step 5: **CSV Export**
- Implement CSV file generation
- Use SwiftUI `FileDocument` + `fileExporter`
- Export format as specified in CLAUDE.md
- Share/save functionality
