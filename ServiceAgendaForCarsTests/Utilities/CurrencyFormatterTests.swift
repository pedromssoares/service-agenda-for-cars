import XCTest
@testable import ServiceAgendaForCars

final class CurrencyFormatterTests: XCTestCase {

    func testFormatCurrencyInteger() throws {
        let formatted = CurrencyFormatter.formatCurrency(100.0)
        XCTAssertEqual(formatted, "$100.00")
    }

    func testFormatCurrencyDecimal() throws {
        let formatted = CurrencyFormatter.formatCurrency(99.99)
        XCTAssertEqual(formatted, "$99.99")
    }

    func testFormatCurrencyZero() throws {
        let formatted = CurrencyFormatter.formatCurrency(0.0)
        XCTAssertEqual(formatted, "$0.00")
    }

    func testFormatCurrencyLargeAmount() throws {
        let formatted = CurrencyFormatter.formatCurrency(1234567.89)
        XCTAssertEqual(formatted, "$1,234,567.89")
    }

    func testFormatCurrencyThreeDecimalPlaces() throws {
        let formatted = CurrencyFormatter.formatCurrency(99.999)
        // Should round to 2 decimal places
        XCTAssertTrue(formatted == "$99.99" || formatted == "$100.00")
    }

    func testFormatCurrencyNegative() throws {
        let formatted = CurrencyFormatter.formatCurrency(-50.0)
        XCTAssertTrue(formatted.contains("-") || formatted.contains("("))
    }

    func testFormatCurrencySmallAmount() throws {
        let formatted = CurrencyFormatter.formatCurrency(0.01)
        XCTAssertEqual(formatted, "$0.01")
    }
}
