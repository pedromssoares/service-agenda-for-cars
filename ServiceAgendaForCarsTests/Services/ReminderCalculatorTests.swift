import XCTest
import SwiftData
@testable import ServiceAgendaForCars

final class ReminderCalculatorTests: XCTestCase {

    // MARK: - Date-Based Reminders

    func testServiceOverdueByDate() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: 90,
            defaultIntervalDistanceKm: nil
        )

        let lastServiceDate = Calendar.current.date(byAdding: .day, value: -100, to: Date())!
        let lastEvent = ServiceEvent(
            date: lastServiceDate,
            odometerKm: 1000.0,
            cost: 50.0,
            notes: nil
        )

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 1500.0)

        let result = ReminderCalculator.calculateNextService(
            for: template,
            lastEvent: lastEvent,
            vehicleOdometerKm: vehicle.currentOdometerKm,
            currentDate: Date(),
            vehicleReminderRule: nil
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.status, .overdue, "Service should be overdue after 100 days with 90 day interval")
        XCTAssertNotNil(result?.daysUntilDue)
        XCTAssertLessThan(result!.daysUntilDue!, 0, "Days until due should be negative for overdue")
    }

    func testServiceDueSoon() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: 90,
            defaultIntervalDistanceKm: nil
        )

        let lastServiceDate = Calendar.current.date(byAdding: .day, value: -70, to: Date())!
        let lastEvent = ServiceEvent(
            date: lastServiceDate,
            odometerKm: 1000.0,
            cost: 50.0,
            notes: nil
        )

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 1500.0)

        let result = ReminderCalculator.calculateNextService(
            for: template,
            lastEvent: lastEvent,
            vehicleOdometerKm: vehicle.currentOdometerKm,
            currentDate: Date(),
            vehicleReminderRule: nil
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.status, .dueSoon, "Service should be due soon within 30 days")
        XCTAssertNotNil(result?.daysUntilDue)
        XCTAssertGreaterThan(result!.daysUntilDue!, 0, "Days until due should be positive")
        XCTAssertLessThanOrEqual(result!.daysUntilDue!, 30, "Due soon should be within 30 days")
    }

    func testServiceUpcoming() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: 90,
            defaultIntervalDistanceKm: nil
        )

        let lastServiceDate = Calendar.current.date(byAdding: .day, value: -50, to: Date())!
        let lastEvent = ServiceEvent(
            date: lastServiceDate,
            odometerKm: 1000.0,
            cost: 50.0,
            notes: nil
        )

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 1500.0)

        let result = ReminderCalculator.calculateNextService(
            for: template,
            lastEvent: lastEvent,
            vehicleOdometerKm: vehicle.currentOdometerKm,
            currentDate: Date(),
            vehicleReminderRule: nil
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.status, .upcoming, "Service should be upcoming (not soon)")
        XCTAssertNotNil(result?.daysUntilDue)
        XCTAssertGreaterThan(result!.daysUntilDue!, 30, "Upcoming should be more than 30 days away")
    }

    // MARK: - Distance-Based Reminders

    func testServiceOverdueByDistance() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: nil,
            defaultIntervalDistanceKm: 5000.0
        )

        let lastEvent = ServiceEvent(
            date: Date(),
            odometerKm: 1000.0,
            cost: 50.0,
            notes: nil
        )

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 7000.0)

        let result = ReminderCalculator.calculateNextService(
            for: template,
            lastEvent: lastEvent,
            vehicleOdometerKm: vehicle.currentOdometerKm,
            currentDate: Date(),
            vehicleReminderRule: nil
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.status, .overdue, "Service should be overdue by distance")
        XCTAssertNotNil(result?.kmUntilDue)
        XCTAssertLessThan(result!.kmUntilDue!, 0, "Km until due should be negative for overdue")
    }

    func testServiceDueSoonByDistance() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: nil,
            defaultIntervalDistanceKm: 5000.0
        )

        let lastEvent = ServiceEvent(
            date: Date(),
            odometerKm: 1000.0,
            cost: 50.0,
            notes: nil
        )

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 5500.0)

        let result = ReminderCalculator.calculateNextService(
            for: template,
            lastEvent: lastEvent,
            vehicleOdometerKm: vehicle.currentOdometerKm,
            currentDate: Date(),
            vehicleReminderRule: nil
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.status, .dueSoon, "Service should be due soon by distance")
        XCTAssertNotNil(result?.kmUntilDue)
        XCTAssertLessThanOrEqual(result!.kmUntilDue!, 1000.0, "Due soon should be within 1000 km")
    }

    // MARK: - Combined Date and Distance

    func testServiceWithBothIntervals_DateCritical() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: 90,
            defaultIntervalDistanceKm: 10000.0
        )

        let lastServiceDate = Calendar.current.date(byAdding: .day, value: -100, to: Date())!
        let lastEvent = ServiceEvent(
            date: lastServiceDate,
            odometerKm: 1000.0,
            cost: 50.0,
            notes: nil
        )

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 2000.0)

        let result = ReminderCalculator.calculateNextService(
            for: template,
            lastEvent: lastEvent,
            vehicleOdometerKm: vehicle.currentOdometerKm,
            currentDate: Date(),
            vehicleReminderRule: nil
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.status, .overdue, "Should be overdue by date even though distance is fine")
    }

    func testServiceWithBothIntervals_DistanceCritical() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: 365,
            defaultIntervalDistanceKm: 5000.0
        )

        let lastServiceDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let lastEvent = ServiceEvent(
            date: lastServiceDate,
            odometerKm: 1000.0,
            cost: 50.0,
            notes: nil
        )

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 7000.0)

        let result = ReminderCalculator.calculateNextService(
            for: template,
            lastEvent: lastEvent,
            vehicleOdometerKm: vehicle.currentOdometerKm,
            currentDate: Date(),
            vehicleReminderRule: nil
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.status, .overdue, "Should be overdue by distance even though date is fine")
    }

    // MARK: - No Last Service

    func testServiceNeverDone() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: 90,
            defaultIntervalDistanceKm: 5000.0
        )

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 5000.0)

        let result = ReminderCalculator.calculateNextService(
            for: template,
            lastEvent: nil,
            vehicleOdometerKm: vehicle.currentOdometerKm,
            currentDate: Date(),
            vehicleReminderRule: nil
        )

        XCTAssertNil(result, "Should return nil when service has never been done")
    }

    // MARK: - Vehicle-Specific Rules

    func testVehicleSpecificRuleOverridesDefault() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: 90,
            defaultIntervalDistanceKm: 5000.0
        )

        let customRule = ReminderRule(
            enabled: true,
            daysInterval: 60, // Custom: 60 days instead of 90
            distanceIntervalKm: 3000.0 // Custom: 3000 km instead of 5000
        )

        let lastServiceDate = Calendar.current.date(byAdding: .day, value: -70, to: Date())!
        let lastEvent = ServiceEvent(
            date: lastServiceDate,
            odometerKm: 1000.0,
            cost: 50.0,
            notes: nil
        )

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 1500.0)

        let result = ReminderCalculator.calculateNextService(
            for: template,
            lastEvent: lastEvent,
            vehicleOdometerKm: vehicle.currentOdometerKm,
            currentDate: Date(),
            vehicleReminderRule: customRule
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.status, .overdue, "Should be overdue based on custom 60-day interval")
    }

    // MARK: - Edge Cases

    func testZeroOdometer() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: nil,
            defaultIntervalDistanceKm: 5000.0
        )

        let lastEvent = ServiceEvent(
            date: Date(),
            odometerKm: 0.0,
            cost: 50.0,
            notes: nil
        )

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 0.0)

        let result = ReminderCalculator.calculateNextService(
            for: template,
            lastEvent: lastEvent,
            vehicleOdometerKm: vehicle.currentOdometerKm,
            currentDate: Date(),
            vehicleReminderRule: nil
        )

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.status, .upcoming, "Should handle zero odometer gracefully")
    }

    func testNoIntervalsSet() throws {
        let template = ServiceTypeTemplate(
            name: "Custom Service",
            defaultIntervalDays: nil,
            defaultIntervalDistanceKm: nil
        )

        let lastEvent = ServiceEvent(
            date: Date(),
            odometerKm: 1000.0,
            cost: 50.0,
            notes: nil
        )

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 2000.0)

        let result = ReminderCalculator.calculateNextService(
            for: template,
            lastEvent: lastEvent,
            vehicleOdometerKm: vehicle.currentOdometerKm,
            currentDate: Date(),
            vehicleReminderRule: nil
        )

        XCTAssertNil(result, "Should return nil when no intervals are set")
    }
}
