# Step 5 Complete: CSV Export

## What was implemented

### 1. CSV Exporter Service
**File:** `ServiceAgendaForCars/Services/Export/CSVExporter.swift`

**Features:**
- Generates CSV content from service events
- Follows format specified in CLAUDE.md:
  ```
  vehicleName,serviceType,dateISO,odometerDisplayed,odometerUnit,cost,notes
  ```
- Sorts events by date (oldest first)
- Proper CSV escaping:
  - Values with commas wrapped in quotes
  - Quotes escaped as double quotes
  - Newlines handled correctly
- Converts odometer to vehicle's display unit (km or mi)
- Formats cost with 2 decimal places
- Uses ISO8601 date format for portability

**Example CSV output:**
```csv
vehicleName,serviceType,dateISO,odometerDisplayed,odometerUnit,cost,notes
Honda Civic,Oil Change,2025-01-15T10:30:00Z,45000,km,89.99,Regular maintenance
Honda Civic,Tire Rotation,2025-04-20T14:00:00Z,50000,km,45.00,
Toyota Camry,Brake Inspection,2025-03-10T09:00:00Z,31069,mi,120.50,"Replaced front pads, everything looks good"
```

### 2. CSV Document
**File:** `ServiceAgendaForCars/Services/Export/CSVDocument.swift`

**SwiftUI FileDocument:**
- Conforms to `FileDocument` protocol
- Content type: `.commaSeparatedText`
- Handles reading and writing CSV files
- Used with `.fileExporter` modifier

### 3. History View Export
**File:** `ServiceAgendaForCars/Features/History/HistoryView.swift`

**Features:**
- "Export CSV" button in toolbar (secondary action)
- Only visible when history exists
- Uses SwiftUI `.fileExporter`:
  - Native iOS file save dialog
  - Can save to Files app
  - Can share to other apps
- Filename format: `service-history-2026-02-05T12:30:00Z.csv`
- Automatic timestamp in filename

### 4. Settings View Export
**File:** `ServiceAgendaForCars/Features/Settings/SettingsView.swift`

**New Data Section:**
- "Export Service History" button
- Shows total service count
- Same export functionality as History view
- Alternative access point for users

## CSV Format Details

### Header Row:
```
vehicleName,serviceType,dateISO,odometerDisplayed,odometerUnit,cost,notes
```

### Field Descriptions:
- **vehicleName**: Vehicle name as entered by user
- **serviceType**: Service type name (Oil Change, Tire Rotation, etc.)
- **dateISO**: ISO8601 format (e.g., 2026-02-05T10:30:00Z)
- **odometerDisplayed**: Odometer reading in display unit (no decimals)
- **odometerUnit**: Either "km" or "mi"
- **cost**: Formatted with 2 decimals, empty if not entered
- **notes**: User notes, properly escaped

### CSV Escaping Rules:
1. Values containing commas → wrapped in quotes
2. Values containing quotes → quotes doubled and wrapped
3. Values containing newlines → wrapped in quotes
4. Empty values → no quotes, just comma

### Example with special characters:
```csv
Honda Civic,"Oil Change, Premium",2025-01-15T10:30:00Z,45000,km,89.99,"Shop said ""looks great"""
```

## How to test

### 1. Basic export:
1. **Build and run** (Cmd+R)
2. **Log a few services** with various data:
   - Different vehicles
   - Different service types
   - Some with cost, some without
   - Some with notes, some without
3. **Go to History tab**
4. **Tap "..." menu** → **Export CSV**
5. **Save dialog appears:**
   - Choose "Save to Files"
   - Select location (e.g., iCloud Drive)
   - Tap "Save"

### 2. Verify CSV content:
1. **Open Files app** on simulator
2. **Navigate to saved location**
3. **Tap the CSV file**
4. **Quick Look preview** shows the CSV
5. **Verify:**
   - Header row present
   - All services included
   - Odometer in correct units per vehicle
   - Dates in ISO format
   - Cost formatted correctly

### 3. Test from Settings:
1. **Go to Settings tab**
2. **Data section:**
   - Shows "Total Services: X"
   - "Export Service History" button
3. **Tap export** → Same save dialog

### 4. Test special characters:
1. **Add service with notes:**
   - "Changed oil, added new filter"
   - Include comma in notes
2. **Export CSV**
3. **Verify notes properly escaped** in quotes

### 5. Test multiple vehicles with different units:
1. **Add 2 vehicles:**
   - Vehicle A: kilometers
   - Vehicle B: miles
2. **Add services for both**
3. **Export CSV**
4. **Verify:**
   - Vehicle A services show km
   - Vehicle B services show mi
   - Odometer values correctly converted

### 6. Test empty history:
1. **Delete all services**
2. **History tab:** No export button (correct)
3. **Settings tab:** Shows "No service history to export"

## Export locations

### iOS Simulator:
- **Files app locations:**
  - iCloud Drive (if signed in)
  - On My iPhone
  - Recently Deleted
- **Share sheet options:**
  - AirDrop
  - Messages
  - Mail
  - Copy

### Real device:
- Same options as simulator
- Can share to any app that accepts CSV
- Can save to cloud services (Dropbox, Google Drive, etc.)

## File naming

**Format:** `service-history-[ISO8601].csv`

**Examples:**
- `service-history-2026-02-05T12:30:45Z.csv`
- `service-history-2026-03-15T09:00:00Z.csv`

**Benefits:**
- Timestamped for version tracking
- Sortable by name
- No conflicts when exporting multiple times

## Use cases

### Personal backup:
- Export regularly for backup
- Store in cloud service
- Import into spreadsheet for analysis

### Data portability:
- Move data to another app
- Import into Excel/Numbers/Google Sheets
- Analyze maintenance patterns

### Sharing with mechanic:
- Export and email full history
- Share via Messages/AirDrop
- Print from spreadsheet app

### Record keeping:
- Attach to insurance claims
- Include in vehicle sale records
- Tax purposes (business vehicles)

## V1 Complete!

All core features are now implemented:
✅ Vehicle management
✅ Service type templates
✅ Service logging
✅ Service history
✅ Up Next reminders
✅ Local notifications
✅ CSV export

The app meets all V1 requirements from CLAUDE.md:
- 100% offline (no backend, no sync)
- Km/mi support (stored in km, displayed in user preference)
- Local notifications (max 40, re-scheduled on launch)
- CSV export (FileDocument + fileExporter)
- No over-engineering

## Next steps (optional enhancements)

**Polish:**
- App icon
- Launch screen
- Better empty states
- Onboarding improvements

**Features for V2:**
- Edit service entries
- Service photos
- Maintenance costs tracking/charts
- Multiple vehicles comparison
- Custom service types
- Reminder customization per vehicle

**Testing:**
- Unit tests for calculators
- UI tests for main flows
- Test on real device
- Beta testing with users
