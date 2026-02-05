# Step 3 Complete: "Up Next" View - Due Services Calculation

## What was implemented

### 1. Vehicle Model Update
**File:** `ServiceAgendaForCars/Models/Vehicle.swift`
- Added `currentOdometerKm` field to track vehicle's current odometer reading
- Stored in kilometers (converted at UI layer like all odometer values)

### 2. Reminder Calculator Service
**File:** `ServiceAgendaForCars/Services/ReminderCalculator.swift`

**Logic:**
- For each vehicle + service type combination:
  - Finds last time that service was performed
  - Calculates due date: `last service date + interval days`
  - Calculates due odometer: `last service odometer + interval km`
  - If never serviced: uses vehicle creation date as baseline

**Status determination:**
- **OVERDUE**: Past due date OR current odometer ≥ due odometer
- **DUE SOON**: Within 30 days OR within 1,000 km
- **UPCOMING**: Everything else

**Sorting:**
- Overdue services first (highest priority)
- Then due soon
- Then upcoming
- Within each category, sorted by most urgent first

### 3. Up Next View with Due Services
**File:** `ServiceAgendaForCars/Features/UpNext/UpNextView.swift`

**Features:**
- Calculates and displays all due services in real-time
- Shows status badge (OVERDUE/DUE SOON/UPCOMING) with color coding:
  - Red: Overdue
  - Orange: Due soon
  - Blue: Upcoming
- For each service shows:
  - Service name and vehicle
  - Date-based reminder (if configured)
  - Distance-based reminder (if configured)
  - Last service date (or "Never serviced")
- Empty states:
  - No vehicles: prompts to add one in Settings
  - All caught up: shows success message
- Toolbar actions:
  - "+" to log a service
  - "Update Odometer" button (secondary action)

### 4. Update Odometer View
**File:** `ServiceAgendaForCars/Features/UpNext/UpdateOdometerView.swift`

**Features:**
- Quick way to update current odometer without logging a service
- Select vehicle (auto-selects if only one)
- Shows current odometer value
- Enter new odometer value in vehicle's preferred unit
- Validates and converts to km for storage

**Access:**
- Up Next tab → toolbar → "Update Odometer"

### 5. Enhanced Edit Vehicle View
**File:** `ServiceAgendaForCars/Features/Settings/EditVehicleView.swift`
- Added current odometer field
- Edit odometer in vehicle's preferred unit
- Saves converted value to km

## How to test

### Basic flow:
1. **Build and run** (Cmd+R)

2. **Set current odometer:**
   - Go to Settings → tap your vehicle
   - Enter current odometer (e.g., 50000)
   - Tap Done

3. **Add a past service:**
   - Go to History → "+"
   - Select your vehicle and "Oil Change"
   - Set date to 60 days ago
   - Enter odometer: 45000
   - Save

4. **Check Up Next tab:**
   - Should show "Oil Change" as DUE SOON or OVERDUE
   - Date reminder: "Due in X days" or "Overdue since..."
   - Distance reminder: "Due in 3000 km" (if current is 50k, last was 45k, interval is 8k)

### Test overdue scenarios:

**Overdue by date:**
- Add service dated 200 days ago
- Should show as OVERDUE with red badge

**Overdue by distance:**
- Add service with odometer 40000
- Set current odometer to 50000
- Oil change interval is 8000 km
- Should show as OVERDUE (due at 48000, current is 50000)

**Due soon:**
- Add service 160 days ago (interval 180 days = due in 20 days)
- Should show DUE SOON with orange badge

### Test multiple vehicles:
1. Add second vehicle with different unit preference
2. Set different current odometers
3. Add services for both
4. Up Next should show due services for both vehicles
5. Each displayed in its vehicle's preferred unit

### Test never serviced:
- Fresh vehicle with no services logged
- Up Next should show all enabled service types
- Calculated from vehicle creation date

## Key implementation details

### Status calculation priority:
- If EITHER date or distance is overdue → OVERDUE
- If EITHER is due soon → DUE SOON
- Otherwise → UPCOMING

### Empty state handling:
- No vehicles: Clear message to add one
- No due services: "All Caught Up!" success message
- Proper ContentUnavailableView for better UX

### Real-time updates:
- Uses SwiftData @Query for reactive updates
- When you log a service or update odometer, Up Next refreshes automatically
- When you change unit preference, displays update automatically

## Next steps

Step 4: **Local Notifications**
- Schedule notifications for due/upcoming services
- Respect 40-notification iOS limit
- Re-schedule on app launch/foreground
- Allow user to enable/disable per service type
