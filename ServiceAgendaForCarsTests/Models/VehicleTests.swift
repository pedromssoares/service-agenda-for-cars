import XCTest
import SwiftData
@testable import ServiceAgendaForCars

final class VehicleTests: XCTestCase {

    func testVehicleInitialization() throws {
        let vehicle = Vehicle(
            name: "Honda Civic",
            unitPreference: .kilometers,
            currentOdometerKm: 10000.0
        )

        XCTAssertEqual(vehicle.name, "Honda Civic")
        XCTAssertEqual(vehicle.unitPreference, .kilometers)
        XCTAssertEqual(vehicle.currentOdometerKm, 10000.0)
        XCTAssertNotNil(vehicle.id)
        XCTAssertNotNil(vehicle.createdAt)
    }

    func testVehicleDefaultOdometer() throws {
        let vehicle = Vehicle(
            name: "Toyota Camry",
            unitPreference: .miles
        )

        XCTAssertEqual(vehicle.currentOdometerKm, 0.0, "Default odometer should be 0")
    }

    func testVehicleUnitPreferenceKilometers() throws {
        let vehicle = Vehicle(
            name: "Test Car",
            unitPreference: .kilometers,
            currentOdometerKm: 5000.0
        )

        XCTAssertEqual(vehicle.unitPreference, .kilometers)
    }

    func testVehicleUnitPreferenceMiles() throws {
        let vehicle = Vehicle(
            name: "Test Car",
            unitPreference: .miles,
            currentOdometerKm: 8046.72 // ~5000 miles
        )

        XCTAssertEqual(vehicle.unitPreference, .miles)
    }

    func testVehicleIDUniqueness() throws {
        let vehicle1 = Vehicle(name: "Car 1", unitPreference: .kilometers)
        let vehicle2 = Vehicle(name: "Car 2", unitPreference: .kilometers)

        XCTAssertNotEqual(vehicle1.id, vehicle2.id, "Each vehicle should have unique ID")
    }

    func testVehicleCreatedAtTimestamp() throws {
        let beforeCreation = Date()
        let vehicle = Vehicle(name: "Test Car", unitPreference: .kilometers)
        let afterCreation = Date()

        XCTAssertGreaterThanOrEqual(vehicle.createdAt, beforeCreation)
        XCTAssertLessThanOrEqual(vehicle.createdAt, afterCreation)
    }

    func testVehicleNameTrimming() throws {
        // Note: Trimming should be done in the UI layer, but test the model accepts it
        let vehicle = Vehicle(
            name: "  Honda Civic  ",
            unitPreference: .kilometers
        )

        XCTAssertEqual(vehicle.name, "  Honda Civic  ", "Model should store name as-is")
    }

    func testVehicleOdometerNegative() throws {
        let vehicle = Vehicle(
            name: "Test Car",
            unitPreference: .kilometers,
            currentOdometerKm: -100.0
        )

        XCTAssertEqual(vehicle.currentOdometerKm, -100.0, "Model accepts negative values (validation should be in UI)")
    }

    func testVehicleOdometerZero() throws {
        let vehicle = Vehicle(
            name: "Brand New Car",
            unitPreference: .kilometers,
            currentOdometerKm: 0.0
        )

        XCTAssertEqual(vehicle.currentOdometerKm, 0.0)
    }

    func testVehicleOdometerLargeValue() throws {
        let vehicle = Vehicle(
            name: "High Mileage Car",
            unitPreference: .kilometers,
            currentOdometerKm: 500000.0
        )

        XCTAssertEqual(vehicle.currentOdometerKm, 500000.0)
    }
}
