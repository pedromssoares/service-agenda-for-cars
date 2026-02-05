import XCTest
import SwiftData
@testable import ServiceAgendaForCars

@MainActor
final class ReminderCalculatorTests: XCTestCase {

    // MARK: - Date-Based Reminders

    func testServiceOverdueByDate() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: 90,
            defaultIntervalDistanceKm: nil
        )
        template.isEnabled = true

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 1500.0)

        let lastServiceDate = Calendar.current.date(byAdding: .day, value: -100, to: Date())!
        let lastEvent = ServiceEvent(
            date: lastServiceDate,
            odometerKm: 1000.0,
            cost: 50.0,
            notes: nil
        )
        lastEvent.vehicle = vehicle
        lastEvent.serviceType = template

        let dueServices = ReminderCalculator.calculateDueServices(
            vehicles: [vehicle],
            serviceTemplates: [template],
            serviceEvents: [lastEvent]
        )

        XCTAssertEqual(dueServices.count, 1)
        let result = dueServices.first!
        XCTAssertEqual(result.status, .overdue, "Service should be overdue after 100 days with 90 day interval")
        XCTAssertNotNil(result.daysUntilDue)
        XCTAssertLessThan(result.daysUntilDue!, 0, "Days until due should be negative for overdue")
    }

    func testServiceDueSoon() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: 90,
            defaultIntervalDistanceKm: nil
        )
        template.isEnabled = true

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 1500.0)

        let lastServiceDate = Calendar.current.date(byAdding: .day, value: -70, to: Date())!
        let lastEvent = ServiceEvent(
            date: lastServiceDate,
            odometerKm: 1000.0,
            cost: 50.0,
            notes: nil
        )
        lastEvent.vehicle = vehicle
        lastEvent.serviceType = template

        let dueServices = ReminderCalculator.calculateDueServices(
            vehicles: [vehicle],
            serviceTemplates: [template],
            serviceEvents: [lastEvent]
        )

        XCTAssertEqual(dueServices.count, 1)
        let result = dueServices.first!
        XCTAssertEqual(result.status, .dueSoon, "Service should be due soon within 30 days")
        XCTAssertNotNil(result.daysUntilDue)
        XCTAssertGreaterThan(result.daysUntilDue!, 0, "Days until due should be positive")
        XCTAssertLessThanOrEqual(result.daysUntilDue!, 30, "Due soon should be within 30 days")
    }

    func testServiceUpcoming() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: 90,
            defaultIntervalDistanceKm: nil
        )
        template.isEnabled = true

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 1500.0)

        let lastServiceDate = Calendar.current.date(byAdding: .day, value: -50, to: Date())!
        let lastEvent = ServiceEvent(
            date: lastServiceDate,
            odometerKm: 1000.0,
            cost: 50.0,
            notes: nil
        )
        lastEvent.vehicle = vehicle
        lastEvent.serviceType = template

        let dueServices = ReminderCalculator.calculateDueServices(
            vehicles: [vehicle],
            serviceTemplates: [template],
            serviceEvents: [lastEvent]
        )

        XCTAssertEqual(dueServices.count, 1)
        let result = dueServices.first!
        XCTAssertEqual(result.status, .upcoming, "Service should be upcoming (not soon)")
        XCTAssertNotNil(result.daysUntilDue)
        XCTAssertGreaterThan(result.daysUntilDue!, 30, "Upcoming should be more than 30 days away")
    }

    // MARK: - Distance-Based Reminders

    func testServiceOverdueByDistance() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: nil,
            defaultIntervalDistanceKm: 5000.0
        )
        template.isEnabled = true

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 7000.0)

        let lastEvent = ServiceEvent(
            date: Date(),
            odometerKm: 1000.0,
            cost: 50.0,
            notes: nil
        )
        lastEvent.vehicle = vehicle
        lastEvent.serviceType = template

        let dueServices = ReminderCalculator.calculateDueServices(
            vehicles: [vehicle],
            serviceTemplates: [template],
            serviceEvents: [lastEvent]
        )

        XCTAssertEqual(dueServices.count, 1)
        let result = dueServices.first!
        XCTAssertEqual(result.status, .overdue, "Service should be overdue by distance")
        XCTAssertNotNil(result.distanceUntilDueKm)
        XCTAssertLessThan(result.distanceUntilDueKm!, 0, "Km until due should be negative for overdue")
    }

    func testServiceDueSoonByDistance() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: nil,
            defaultIntervalDistanceKm: 5000.0
        )
        template.isEnabled = true

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 5500.0)

        let lastEvent = ServiceEvent(
            date: Date(),
            odometerKm: 1000.0,
            cost: 50.0,
            notes: nil
        )
        lastEvent.vehicle = vehicle
        lastEvent.serviceType = template

        let dueServices = ReminderCalculator.calculateDueServices(
            vehicles: [vehicle],
            serviceTemplates: [template],
            serviceEvents: [lastEvent]
        )

        XCTAssertEqual(dueServices.count, 1)
        let result = dueServices.first!
        XCTAssertEqual(result.status, .dueSoon, "Service should be due soon by distance")
        XCTAssertNotNil(result.distanceUntilDueKm)
        XCTAssertLessThanOrEqual(result.distanceUntilDueKm!, 1000.0, "Due soon should be within 1000 km")
    }

    // MARK: - Combined Date and Distance

    func testServiceWithBothIntervals_DateCritical() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: 90,
            defaultIntervalDistanceKm: 10000.0
        )
        template.isEnabled = true

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 2000.0)

        let lastServiceDate = Calendar.current.date(byAdding: .day, value: -100, to: Date())!
        let lastEvent = ServiceEvent(
            date: lastServiceDate,
            odometerKm: 1000.0,
            cost: 50.0,
            notes: nil
        )
        lastEvent.vehicle = vehicle
        lastEvent.serviceType = template

        let dueServices = ReminderCalculator.calculateDueServices(
            vehicles: [vehicle],
            serviceTemplates: [template],
            serviceEvents: [lastEvent]
        )

        XCTAssertEqual(dueServices.count, 1)
        let result = dueServices.first!
        XCTAssertEqual(result.status, .overdue, "Should be overdue by date even though distance is fine")
    }

    func testServiceWithBothIntervals_DistanceCritical() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: 365,
            defaultIntervalDistanceKm: 5000.0
        )
        template.isEnabled = true

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 7000.0)

        let lastServiceDate = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let lastEvent = ServiceEvent(
            date: lastServiceDate,
            odometerKm: 1000.0,
            cost: 50.0,
            notes: nil
        )
        lastEvent.vehicle = vehicle
        lastEvent.serviceType = template

        let dueServices = ReminderCalculator.calculateDueServices(
            vehicles: [vehicle],
            serviceTemplates: [template],
            serviceEvents: [lastEvent]
        )

        XCTAssertEqual(dueServices.count, 1)
        let result = dueServices.first!
        XCTAssertEqual(result.status, .overdue, "Should be overdue by distance even though date is fine")
    }

    // MARK: - No Last Service

    func testServiceNeverDone() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: 90,
            defaultIntervalDistanceKm: 5000.0
        )
        template.isEnabled = true

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 5000.0)

        let dueServices = ReminderCalculator.calculateDueServices(
            vehicles: [vehicle],
            serviceTemplates: [template],
            serviceEvents: []
        )

        XCTAssertEqual(dueServices.count, 1, "Should still create a due service entry")
        let result = dueServices.first!
        XCTAssertNil(result.lastServiceDate, "Should have no last service date")
        XCTAssertNil(result.lastServiceOdometerKm, "Should have no last service odometer")
    }

    // MARK: - Vehicle-Specific Rules

    func testVehicleSpecificRuleOverridesDefault() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: 90,
            defaultIntervalDistanceKm: 5000.0
        )
        template.isEnabled = true

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 1500.0)

        let customRule = ReminderRule(
            enabled: true,
            daysInterval: 60, // Custom: 60 days instead of 90
            distanceIntervalKm: 3000.0 // Custom: 3000 km instead of 5000
        )
        customRule.vehicle = vehicle
        customRule.serviceType = template
        vehicle.reminderRules = [customRule]

        let lastServiceDate = Calendar.current.date(byAdding: .day, value: -70, to: Date())!
        let lastEvent = ServiceEvent(
            date: lastServiceDate,
            odometerKm: 1000.0,
            cost: 50.0,
            notes: nil
        )
        lastEvent.vehicle = vehicle
        lastEvent.serviceType = template

        let dueServices = ReminderCalculator.calculateDueServices(
            vehicles: [vehicle],
            serviceTemplates: [template],
            serviceEvents: [lastEvent]
        )

        XCTAssertEqual(dueServices.count, 1)
        let result = dueServices.first!
        XCTAssertEqual(result.status, .overdue, "Should be overdue based on custom 60-day interval")
    }

    // MARK: - Multiple Vehicles

    func testMultipleVehicles() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: 90,
            defaultIntervalDistanceKm: 5000.0
        )
        template.isEnabled = true

        let vehicle1 = Vehicle(name: "Car 1", unitPreference: .kilometers, currentOdometerKm: 1500.0)
        let vehicle2 = Vehicle(name: "Car 2", unitPreference: .miles, currentOdometerKm: 2000.0)

        let event1 = ServiceEvent(date: Date(), odometerKm: 1000.0, cost: 50.0, notes: nil)
        event1.vehicle = vehicle1
        event1.serviceType = template

        let event2 = ServiceEvent(date: Date(), odometerKm: 1500.0, cost: 60.0, notes: nil)
        event2.vehicle = vehicle2
        event2.serviceType = template

        let dueServices = ReminderCalculator.calculateDueServices(
            vehicles: [vehicle1, vehicle2],
            serviceTemplates: [template],
            serviceEvents: [event1, event2]
        )

        XCTAssertEqual(dueServices.count, 2, "Should calculate services for both vehicles")
    }

    // MARK: - Disabled Template

    func testDisabledTemplateNotIncluded() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: 90,
            defaultIntervalDistanceKm: 5000.0
        )
        template.isEnabled = false // Disabled

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 1500.0)

        let dueServices = ReminderCalculator.calculateDueServices(
            vehicles: [vehicle],
            serviceTemplates: [template],
            serviceEvents: []
        )

        XCTAssertEqual(dueServices.count, 0, "Disabled templates should not generate due services")
    }

    // MARK: - Sorting

    func testDueServicesSortedByPriority() throws {
        let template1 = ServiceTypeTemplate(name: "Service 1", defaultIntervalDays: 90, defaultIntervalDistanceKm: nil)
        template1.isEnabled = true

        let template2 = ServiceTypeTemplate(name: "Service 2", defaultIntervalDays: 90, defaultIntervalDistanceKm: nil)
        template2.isEnabled = true

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 5000.0)

        // Service 1: Overdue by 10 days
        let event1Date = Calendar.current.date(byAdding: .day, value: -100, to: Date())!
        let event1 = ServiceEvent(date: event1Date, odometerKm: 1000.0, cost: 50.0, notes: nil)
        event1.vehicle = vehicle
        event1.serviceType = template1

        // Service 2: Due soon (20 days away)
        let event2Date = Calendar.current.date(byAdding: .day, value: -70, to: Date())!
        let event2 = ServiceEvent(date: event2Date, odometerKm: 2000.0, cost: 60.0, notes: nil)
        event2.vehicle = vehicle
        event2.serviceType = template2

        let dueServices = ReminderCalculator.calculateDueServices(
            vehicles: [vehicle],
            serviceTemplates: [template1, template2],
            serviceEvents: [event1, event2]
        )

        XCTAssertEqual(dueServices.count, 2)
        XCTAssertEqual(dueServices[0].status, .overdue, "Overdue service should be first")
        XCTAssertEqual(dueServices[1].status, .dueSoon, "Due soon service should be second")
    }

    // MARK: - Edge Cases

    func testZeroOdometer() throws {
        let template = ServiceTypeTemplate(
            name: "Oil Change",
            defaultIntervalDays: nil,
            defaultIntervalDistanceKm: 5000.0
        )
        template.isEnabled = true

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 0.0)

        let lastEvent = ServiceEvent(date: Date(), odometerKm: 0.0, cost: 50.0, notes: nil)
        lastEvent.vehicle = vehicle
        lastEvent.serviceType = template

        let dueServices = ReminderCalculator.calculateDueServices(
            vehicles: [vehicle],
            serviceTemplates: [template],
            serviceEvents: [lastEvent]
        )

        XCTAssertEqual(dueServices.count, 1, "Should handle zero odometer gracefully")
    }

    func testNoIntervalsSet() throws {
        let template = ServiceTypeTemplate(
            name: "Custom Service",
            defaultIntervalDays: nil,
            defaultIntervalDistanceKm: nil
        )
        template.isEnabled = true

        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers, currentOdometerKm: 2000.0)

        let lastEvent = ServiceEvent(date: Date(), odometerKm: 1000.0, cost: 50.0, notes: nil)
        lastEvent.vehicle = vehicle
        lastEvent.serviceType = template

        let dueServices = ReminderCalculator.calculateDueServices(
            vehicles: [vehicle],
            serviceTemplates: [template],
            serviceEvents: [lastEvent]
        )

        XCTAssertEqual(dueServices.count, 1, "Should create entry even with no intervals")
        let result = dueServices.first!
        XCTAssertNil(result.dueDateByDate, "Should have no due date")
        XCTAssertNil(result.dueOdometerKm, "Should have no due odometer")
    }
}
