import XCTest
@testable import ServiceAgendaForCars

final class DistanceFormatterTests: XCTestCase {

    // MARK: - Kilometers to Miles Conversion

    func testKilometersToMiles() throws {
        let km = 100.0
        let miles = DistanceFormatter.toDisplayValue(km, unit: .miles)

        XCTAssertEqual(miles, 62.1371, accuracy: 0.0001, "100 km should convert to ~62.1371 miles")
    }

    func testZeroKilometersToMiles() throws {
        let km = 0.0
        let miles = DistanceFormatter.toDisplayValue(km, unit: .miles)

        XCTAssertEqual(miles, 0.0, "0 km should convert to 0 miles")
    }

    func testLargeKilometersToMiles() throws {
        let km = 100000.0
        let miles = DistanceFormatter.toDisplayValue(km, unit: .miles)

        XCTAssertEqual(miles, 62137.1, accuracy: 0.1, "100,000 km should convert to ~62,137 miles")
    }

    // MARK: - Miles to Kilometers Conversion

    func testMilesToKilometers() throws {
        let miles = 100.0
        let km = DistanceFormatter.toStoredValue(miles, unit: .miles)

        XCTAssertEqual(km, 160.934, accuracy: 0.001, "100 miles should convert to ~160.934 km")
    }

    func testZeroMilesToKilometers() throws {
        let miles = 0.0
        let km = DistanceFormatter.toStoredValue(miles, unit: .miles)

        XCTAssertEqual(km, 0.0, "0 miles should convert to 0 km")
    }

    // MARK: - Kilometers to Kilometers (No Conversion)

    func testKilometersToKilometers() throws {
        let km = 1000.0
        let result = DistanceFormatter.toDisplayValue(km, unit: .kilometers)

        XCTAssertEqual(result, km, "Kilometers to kilometers should return same value")
    }

    func testStoredKilometersToKilometers() throws {
        let km = 1000.0
        let result = DistanceFormatter.toStoredValue(km, unit: .kilometers)

        XCTAssertEqual(result, km, "Kilometers to stored kilometers should return same value")
    }

    // MARK: - Round Trip Conversion

    func testRoundTripConversion() throws {
        let originalKm = 5000.0
        let miles = DistanceFormatter.toDisplayValue(originalKm, unit: .miles)
        let backToKm = DistanceFormatter.toStoredValue(miles, unit: .miles)

        XCTAssertEqual(originalKm, backToKm, accuracy: 0.02, "Round trip conversion should preserve value within reasonable accuracy")
    }

    // MARK: - Format Distance String

    func testFormatDistanceKilometers() throws {
        let formatted = DistanceFormatter.formatDistance(1000, unit: .kilometers)
        XCTAssertEqual(formatted, "1000 km", "Format uses no thousands separator")
    }

    func testFormatDistanceMiles() throws {
        let km = 1.60934 // ~1 mile
        let formatted = DistanceFormatter.formatDistance(km, unit: .miles)
        XCTAssertEqual(formatted, "1 mi")
    }

    func testFormatDistanceZero() throws {
        let formatted = DistanceFormatter.formatDistance(0, unit: .kilometers)
        XCTAssertEqual(formatted, "0 km")
    }

    func testFormatDistanceDecimal() throws {
        let formatted = DistanceFormatter.formatDistance(1234.56, unit: .kilometers)
        XCTAssertEqual(formatted, "1235 km", "Should round to nearest integer")
    }

    // MARK: - Edge Cases

    func testNegativeDistance() throws {
        let km = -100.0
        let miles = DistanceFormatter.toDisplayValue(km, unit: .miles)

        XCTAssertLessThan(miles, 0, "Negative values should remain negative")
    }

    func testVerySmallDistance() throws {
        let km = 0.5
        let miles = DistanceFormatter.toDisplayValue(km, unit: .miles)

        XCTAssertGreaterThan(miles, 0, "Small positive values should remain positive")
        XCTAssertEqual(miles, 0.310686, accuracy: 0.00001)
    }
}
