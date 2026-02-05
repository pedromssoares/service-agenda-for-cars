import XCTest
import SwiftData
@testable import ServiceAgendaForCars

final class ServiceEventTests: XCTestCase {

    func testServiceEventInitialization() throws {
        let date = Date()
        let event = ServiceEvent(
            date: date,
            odometerKm: 5000.0,
            cost: 50.0,
            notes: "Oil change completed"
        )

        XCTAssertEqual(event.date, date)
        XCTAssertEqual(event.odometerKm, 5000.0)
        XCTAssertEqual(event.cost, 50.0)
        XCTAssertEqual(event.notes, "Oil change completed")
        XCTAssertNotNil(event.id)
    }

    func testServiceEventWithNilValues() throws {
        let event = ServiceEvent(
            date: Date(),
            odometerKm: 5000.0,
            cost: nil,
            notes: nil
        )

        XCTAssertNil(event.cost)
        XCTAssertNil(event.notes)
    }

    func testServiceEventPhotosEmpty() throws {
        let event = ServiceEvent(
            date: Date(),
            odometerKm: 5000.0,
            cost: 50.0,
            notes: nil
        )

        XCTAssertTrue(event.photos.isEmpty, "New event should have no photos")
        XCTAssertNil(event.photoData1)
        XCTAssertNil(event.photoData2)
        XCTAssertNil(event.photoData3)
        XCTAssertNil(event.photoData4)
        XCTAssertNil(event.photoData5)
    }

    func testServiceEventSetPhotos() throws {
        let event = ServiceEvent(
            date: Date(),
            odometerKm: 5000.0,
            cost: 50.0,
            notes: nil
        )

        let photo1 = Data([1, 2, 3])
        let photo2 = Data([4, 5, 6])
        let photo3 = Data([7, 8, 9])

        event.setPhotos([photo1, photo2, photo3])

        XCTAssertEqual(event.photos.count, 3)
        XCTAssertEqual(event.photoData1, photo1)
        XCTAssertEqual(event.photoData2, photo2)
        XCTAssertEqual(event.photoData3, photo3)
        XCTAssertNil(event.photoData4)
        XCTAssertNil(event.photoData5)
    }

    func testServiceEventSetPhotosMaximum() throws {
        let event = ServiceEvent(
            date: Date(),
            odometerKm: 5000.0,
            cost: 50.0,
            notes: nil
        )

        let photos = [
            Data([1]),
            Data([2]),
            Data([3]),
            Data([4]),
            Data([5])
        ]

        event.setPhotos(photos)

        XCTAssertEqual(event.photos.count, 5, "Should support up to 5 photos")
    }

    func testServiceEventSetPhotosExceedsMaximum() throws {
        let event = ServiceEvent(
            date: Date(),
            odometerKm: 5000.0,
            cost: 50.0,
            notes: nil
        )

        let photos = [
            Data([1]),
            Data([2]),
            Data([3]),
            Data([4]),
            Data([5]),
            Data([6]), // 6th photo should be ignored
            Data([7])
        ]

        event.setPhotos(photos)

        XCTAssertEqual(event.photos.count, 5, "Should limit to 5 photos")
        XCTAssertNil(event.photoData5?.first(where: { $0 == 6 }), "6th photo should not be stored")
    }

    func testServiceEventClearPhotos() throws {
        let event = ServiceEvent(
            date: Date(),
            odometerKm: 5000.0,
            cost: 50.0,
            notes: nil
        )

        event.setPhotos([Data([1]), Data([2])])
        XCTAssertEqual(event.photos.count, 2)

        event.setPhotos([])
        XCTAssertTrue(event.photos.isEmpty, "Setting empty array should clear all photos")
        XCTAssertNil(event.photoData1)
        XCTAssertNil(event.photoData2)
    }

    func testServiceEventZeroCost() throws {
        let event = ServiceEvent(
            date: Date(),
            odometerKm: 5000.0,
            cost: 0.0,
            notes: "Free service"
        )

        XCTAssertEqual(event.cost, 0.0)
    }

    func testServiceEventNegativeCost() throws {
        let event = ServiceEvent(
            date: Date(),
            odometerKm: 5000.0,
            cost: -50.0,
            notes: "Refund"
        )

        XCTAssertEqual(event.cost, -50.0, "Model accepts negative cost (for refunds/credits)")
    }

    func testServiceEventLargeCost() throws {
        let event = ServiceEvent(
            date: Date(),
            odometerKm: 5000.0,
            cost: 999999.99,
            notes: "Major repair"
        )

        XCTAssertEqual(event.cost, 999999.99)
    }

    func testServiceEventZeroOdometer() throws {
        let event = ServiceEvent(
            date: Date(),
            odometerKm: 0.0,
            cost: 50.0,
            notes: "First service"
        )

        XCTAssertEqual(event.odometerKm, 0.0)
    }

    func testServiceEventIDUniqueness() throws {
        let event1 = ServiceEvent(date: Date(), odometerKm: 1000.0, cost: 50.0, notes: nil)
        let event2 = ServiceEvent(date: Date(), odometerKm: 2000.0, cost: 75.0, notes: nil)

        XCTAssertNotEqual(event1.id, event2.id, "Each event should have unique ID")
    }

    func testServiceEventNotesLongText() throws {
        let longNotes = String(repeating: "This is a long note. ", count: 100)
        let event = ServiceEvent(
            date: Date(),
            odometerKm: 5000.0,
            cost: 50.0,
            notes: longNotes
        )

        XCTAssertEqual(event.notes, longNotes, "Should handle long notes")
    }

    func testServiceEventNotesSpecialCharacters() throws {
        let notes = "Oil change completed ✓\nFilter replaced\nCost: $50.00"
        let event = ServiceEvent(
            date: Date(),
            odometerKm: 5000.0,
            cost: 50.0,
            notes: notes
        )

        XCTAssertEqual(event.notes, notes, "Should handle special characters and newlines")
    }
}
