# Widget Extension Setup Instructions

The widget extension has been created with all necessary code files. However, you need to manually configure the Xcode project to add the widget target and set up App Groups for data sharing.

## Step 1: Add Widget Extension Target

1. Open the project in Xcode
2. Select the project file in the navigator
3. Click the "+" button at the bottom of the targets list
4. Select "Widget Extension"
5. Product Name: `ServiceAgendaWidget`
6. Uncheck "Include Configuration Intent"
7. Click "Finish"
8. Click "Activate" when prompted about the scheme

## Step 2: Configure App Groups

App Groups allow the main app and widget to share data through SwiftData.

### For Main App Target:
1. Select the **ServiceAgendaForCars** target
2. Go to "Signing & Capabilities"
3. Click "+ Capability"
4. Add "App Groups"
5. Click "+" under App Groups
6. Enter: `group.com.serviceagenda.shared`
7. Enable the checkbox

### For Widget Target:
1. Select the **ServiceAgendaWidget** target
2. Go to "Signing & Capabilities"
3. Click "+ Capability"
4. Add "App Groups"
5. Click "+" under App Groups
6. Enter: `group.com.serviceagenda.shared` (same as main app)
7. Enable the checkbox

## Step 3: Add Files to Widget Target

The widget needs access to shared models and utilities:

1. In the Project Navigator, select each of the following files
2. In the File Inspector (right panel), under "Target Membership"
3. Check both **ServiceAgendaForCars** AND **ServiceAgendaWidget**

Files to add to both targets:
- `Models/Vehicle.swift`
- `Models/ServiceEvent.swift`
- `Models/ServiceTypeTemplate.swift`
- `Models/ReminderRule.swift`
- `Services/ReminderCalculator.swift`
- `Shared/Formatting/DistanceFormatter.swift`
- `Shared/Themes/ColorTheme.swift`

## Step 4: Update Model Container Configuration

The app's ModelContainer needs to use App Groups. This change is already in the code, but verify:

In `ServiceAgendaForCarsApp.swift`, the ModelContainer should use:
```swift
ModelConfiguration(groupContainer: .identifier("group.com.serviceagenda.shared"))
```

## Step 5: Build and Run

1. Build the main app target
2. Run on simulator or device
3. Add a vehicle and some service history
4. Close the app
5. On the home screen, long press to enter edit mode
6. Tap "+" to add widget
7. Search for "Service Agenda" or "Next Service"
8. Add the widget to see your next due service

## Widget Features

### Home Screen Widgets:
- **Small Widget**: Shows next service with status badge and days/km until due
- **Medium Widget**: Shows next service with vehicle name and detailed countdown

### Lock Screen Widgets (iOS 16+):
- **Circular**: Shows days until next service in a compact circular format
- **Rectangular**: Shows service name and countdown in a rectangular format

### Widget Updates:
- Widget refreshes every hour automatically
- Widget updates when you open the main app
- Widget shows the most urgent service (overdue → due soon → upcoming)

## Troubleshooting

**Widget shows "No services due" but app has services:**
- Make sure App Groups are configured correctly for both targets
- Verify the group identifier is exactly: `group.com.serviceagenda.shared`
- Check that all model files are added to the widget target
- Delete and reinstall the app to recreate the shared container

**Build errors:**
- Clean build folder (Cmd+Shift+K)
- Close and reopen Xcode
- Verify all shared files have both targets checked

**Widget not updating:**
- Widgets update every hour by default
- Open the main app to trigger an immediate update
- Remove and re-add the widget
