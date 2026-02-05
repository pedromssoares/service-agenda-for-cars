# Service Agenda for Cars - Test Suite

Comprehensive test suite for the Service Agenda for Cars iOS application.

## Test Coverage

### Utilities
- **DistanceFormatterTests**: Unit conversion (km ↔ miles), formatting, edge cases
- **CurrencyFormatterTests**: Currency formatting, localization, edge cases

### Services
- **ReminderCalculatorTests**: Core business logic for service reminders
  - Date-based reminders (overdue, due soon, upcoming)
  - Distance-based reminders
  - Combined date and distance intervals
  - Vehicle-specific rules override defaults
  - Edge cases (no intervals, zero odometer, etc.)

- **CSVExporterTests**: Export functionality
  - CSV format correctness
  - Special character escaping (commas, quotes, newlines)
  - Unit conversion in export
  - Handling nil values
  - Date formatting

### Models
- **VehicleTests**: Vehicle model validation
  - Initialization
  - Unit preferences
  - Odometer values
  - ID uniqueness

- **ServiceEventTests**: Service event model
  - Initialization with various parameters
  - Photo management (up to 5 photos)
  - Cost handling (nil, zero, negative)
  - Notes handling (special characters, long text)

## Running Tests

### In Xcode
1. Open the project in Xcode
2. Press `Cmd+U` to run all tests
3. Or select Product → Test from menu

### Run Specific Test Suite
1. Open Test Navigator (Cmd+6)
2. Click on specific test suite or test
3. Click the play button next to the test

### Command Line
```bash
xcodebuild test \
  -scheme ServiceAgendaForCars \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test Organization

```
ServiceAgendaForCarsTests/
├── Models/
│   ├── VehicleTests.swift
│   └── ServiceEventTests.swift
├── Services/
│   ├── ReminderCalculatorTests.swift
│   └── CSVExporterTests.swift
├── Utilities/
│   ├── DistanceFormatterTests.swift
│   └── CurrencyFormatterTests.swift
└── README.md
```

## Test Principles

1. **Unit Tests**: Test individual components in isolation
2. **Edge Cases**: Test boundary conditions and error cases
3. **Data Validation**: Ensure models handle various input correctly
4. **Business Logic**: Verify core reminder calculation logic
5. **Format Validation**: Ensure output formats are correct

## Coverage Areas

✅ Distance unit conversion (km/mi)
✅ Currency formatting
✅ Service reminder calculations
✅ Date-based reminders
✅ Distance-based reminders
✅ Vehicle-specific reminder rules
✅ CSV export with proper escaping
✅ Model initialization and validation
✅ Photo management (up to 5 per service)
✅ Edge cases and error conditions

## Future Test Additions

- [ ] UI Tests for critical user flows
- [ ] Integration tests with SwiftData
- [ ] Notification scheduling tests
- [ ] Widget data sharing tests
- [ ] Performance tests for large datasets
- [ ] Accessibility tests

## Test Data

Tests use in-memory models and do not require a database. All test data is created programmatically within each test case.

## Continuous Integration

Tests are designed to run in CI environments. Ensure you have:
- Xcode 15.0+
- iOS 17.0+ SDK
- Simulator configured

## Debugging Tests

- Set breakpoints in test code
- Use `XCTAssert` for clear failure messages
- Check test logs in Xcode's Report Navigator
- Run individual tests to isolate failures

## Contributing

When adding new features:
1. Write tests first (TDD approach recommended)
2. Ensure all tests pass before committing
3. Add tests for edge cases
4. Update this README if adding new test categories
