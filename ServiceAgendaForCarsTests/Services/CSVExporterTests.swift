import XCTest
import SwiftData
@testable import ServiceAgendaForCars

final class CSVExporterTests: XCTestCase {

    func testGenerateCSVHeader() throws {
        let csv = CSVExporter.generateCSV(from: [])

        XCTAssertTrue(csv.hasPrefix("Vehicle,Service Type,Date,Odometer,Unit,Cost,Notes"))
    }

    func testGenerateCSVWithSingleEvent() throws {
        let vehicle = Vehicle(name: "Honda Civic", unitPreference: .kilometers, currentOdometerKm: 10000)
        let template = ServiceTypeTemplate(name: "Oil Change", defaultIntervalDays: 90, defaultIntervalDistanceKm: 5000)

        let event = ServiceEvent(
            date: Date(),
            odometerKm: 5000.0,
            cost: 50.0,
            notes: "Regular service"
        )
        event.vehicle = vehicle
        event.serviceType = template

        let csv = CSVExporter.generateCSV(from: [event])

        XCTAssertTrue(csv.contains("Honda Civic"))
        XCTAssertTrue(csv.contains("Oil Change"))
        XCTAssertTrue(csv.contains("5000") || csv.contains("5,000"))
        XCTAssertTrue(csv.contains("km"))
        XCTAssertTrue(csv.contains("50") || csv.contains("50.0"))
        XCTAssertTrue(csv.contains("Regular service"))
    }

    func testGenerateCSVWithMultipleEvents() throws {
        let vehicle1 = Vehicle(name: "Honda Civic", unitPreference: .kilometers, currentOdometerKm: 10000)
        let vehicle2 = Vehicle(name: "Toyota Camry", unitPreference: .miles, currentOdometerKm: 16093.4)

        let template1 = ServiceTypeTemplate(name: "Oil Change", defaultIntervalDays: 90, defaultIntervalDistanceKm: 5000)
        let template2 = ServiceTypeTemplate(name: "Tire Rotation", defaultIntervalDays: 180, defaultIntervalDistanceKm: 10000)

        let event1 = ServiceEvent(date: Date(), odometerKm: 5000.0, cost: 50.0, notes: nil)
        event1.vehicle = vehicle1
        event1.serviceType = template1

        let event2 = ServiceEvent(date: Date(), odometerKm: 16093.4, cost: 75.0, notes: nil)
        event2.vehicle = vehicle2
        event2.serviceType = template2

        let csv = CSVExporter.generateCSV(from: [event1, event2])

        let lines = csv.components(separatedBy: "\n")
        XCTAssertEqual(lines.count, 3, "Should have header + 2 data rows")
    }

    func testCSVEscapesCommasInNotes() throws {
        let vehicle = Vehicle(name: "Honda Civic", unitPreference: .kilometers, currentOdometerKm: 10000)
        let template = ServiceTypeTemplate(name: "Oil Change", defaultIntervalDays: 90, defaultIntervalDistanceKm: 5000)

        let event = ServiceEvent(
            date: Date(),
            odometerKm: 5000.0,
            cost: 50.0,
            notes: "Changed oil, filter, and air filter"
        )
        event.vehicle = vehicle
        event.serviceType = template

        let csv = CSVExporter.generateCSV(from: [event])

        XCTAssertTrue(csv.contains("\"Changed oil, filter, and air filter\""), "Notes with commas should be quoted")
    }

    func testCSVEscapesQuotesInNotes() throws {
        let vehicle = Vehicle(name: "Honda Civic", unitPreference: .kilometers, currentOdometerKm: 10000)
        let template = ServiceTypeTemplate(name: "Oil Change", defaultIntervalDays: 90, defaultIntervalDistanceKm: 5000)

        let event = ServiceEvent(
            date: Date(),
            odometerKm: 5000.0,
            cost: 50.0,
            notes: "Mechanic said \"everything looks good\""
        )
        event.vehicle = vehicle
        event.serviceType = template

        let csv = CSVExporter.generateCSV(from: [event])

        XCTAssertTrue(csv.contains("\"\""), "Quotes should be escaped with double quotes")
    }

    func testCSVHandlesNilNotes() throws {
        let vehicle = Vehicle(name: "Honda Civic", unitPreference: .kilometers, currentOdometerKm: 10000)
        let template = ServiceTypeTemplate(name: "Oil Change", defaultIntervalDays: 90, defaultIntervalDistanceKm: 5000)

        let event = ServiceEvent(
            date: Date(),
            odometerKm: 5000.0,
            cost: 50.0,
            notes: nil
        )
        event.vehicle = vehicle
        event.serviceType = template

        let csv = CSVExporter.generateCSV(from: [event])

        let lines = csv.components(separatedBy: "\n")
        XCTAssertTrue(lines[1].hasSuffix(","), "Nil notes should result in empty field")
    }

    func testCSVHandlesNilCost() throws {
        let vehicle = Vehicle(name: "Honda Civic", unitPreference: .kilometers, currentOdometerKm: 10000)
        let template = ServiceTypeTemplate(name: "Oil Change", defaultIntervalDays: 90, defaultIntervalDistanceKm: 5000)

        let event = ServiceEvent(
            date: Date(),
            odometerKm: 5000.0,
            cost: nil,
            notes: "Free service"
        )
        event.vehicle = vehicle
        event.serviceType = template

        let csv = CSVExporter.generateCSV(from: [event])

        XCTAssertTrue(csv.contains("Free service"))
        // Cost field should be empty or 0
        let lines = csv.components(separatedBy: "\n")
        let dataLine = lines[1]
        XCTAssertFalse(dataLine.contains("nil"))
    }

    func testCSVConvertsOdometerToMiles() throws {
        let vehicle = Vehicle(name: "Honda Civic", unitPreference: .miles, currentOdometerKm: 10000)
        let template = ServiceTypeTemplate(name: "Oil Change", defaultIntervalDays: 90, defaultIntervalDistanceKm: 5000)

        let event = ServiceEvent(
            date: Date(),
            odometerKm: 8046.72, // ~5000 miles in km
            cost: 50.0,
            notes: nil
        )
        event.vehicle = vehicle
        event.serviceType = template

        let csv = CSVExporter.generateCSV(from: [event])

        XCTAssertTrue(csv.contains("mi"), "Should use miles unit")
        XCTAssertTrue(csv.contains("5000"), "Should convert km to miles for display")
    }

    func testCSVDateFormat() throws {
        let vehicle = Vehicle(name: "Honda Civic", unitPreference: .kilometers, currentOdometerKm: 10000)
        let template = ServiceTypeTemplate(name: "Oil Change", defaultIntervalDays: 90, defaultIntervalDistanceKm: 5000)

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        let specificDate = dateFormatter.date(from: "2024-01-15")!

        let event = ServiceEvent(
            date: specificDate,
            odometerKm: 5000.0,
            cost: 50.0,
            notes: nil
        )
        event.vehicle = vehicle
        event.serviceType = template

        let csv = CSVExporter.generateCSV(from: [event])

        XCTAssertTrue(csv.contains("2024-01-15"), "Should use ISO8601 date format")
    }

    func testCSVHandlesSpecialCharactersInVehicleName() throws {
        let vehicle = Vehicle(name: "John's \"Awesome\" Car, 2024", unitPreference: .kilometers, currentOdometerKm: 10000)
        let template = ServiceTypeTemplate(name: "Oil Change", defaultIntervalDays: 90, defaultIntervalDistanceKm: 5000)

        let event = ServiceEvent(
            date: Date(),
            odometerKm: 5000.0,
            cost: 50.0,
            notes: nil
        )
        event.vehicle = vehicle
        event.serviceType = template

        let csv = CSVExporter.generateCSV(from: [event])

        XCTAssertTrue(csv.contains("\"John's \"\"Awesome\"\" Car, 2024\""), "Should properly escape vehicle name")
    }

    func testEmptyEventsArray() throws {
        let csv = CSVExporter.generateCSV(from: [])

        let lines = csv.components(separatedBy: "\n")
        XCTAssertEqual(lines.count, 1, "Should only have header line")
    }
}
