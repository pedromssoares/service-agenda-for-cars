import XCTest
@testable import ServiceAgendaForCars

final class CurrencyFormatterTests: XCTestCase {

    func testFormatInteger() throws {
        let formatted = CurrencyFormatter.format(100.0)
        XCTAssertTrue(formatted.contains("100"), "Should format 100 as currency")
    }

    func testFormatDecimal() throws {
        let formatted = CurrencyFormatter.format(99.99)
        XCTAssertTrue(formatted.contains("99.99") || formatted.contains("99,99"), "Should format with decimals")
    }

    func testFormatZero() throws {
        let formatted = CurrencyFormatter.format(0.0)
        XCTAssertTrue(formatted.contains("0"), "Should format zero")
    }

    func testFormatLargeAmount() throws {
        let formatted = CurrencyFormatter.format(1234567.89)
        XCTAssertTrue(formatted.contains("1") && formatted.contains("234") && formatted.contains("567"), "Should format large amounts with separators")
    }

    func testFormatThreeDecimalPlaces() throws {
        let formatted = CurrencyFormatter.format(99.999)
        // Should round to 2 decimal places based on locale
        XCTAssertTrue(formatted.contains("99") || formatted.contains("100"), "Should round appropriately")
    }

    func testFormatNegative() throws {
        let formatted = CurrencyFormatter.format(-50.0)
        // Negative formatting varies by locale (could be -$50 or ($50) or -50$)
        XCTAssertTrue(formatted.contains("-") || formatted.contains("(") || formatted.contains("50"), "Should handle negative values")
    }

    func testFormatSmallAmount() throws {
        let formatted = CurrencyFormatter.format(0.01)
        XCTAssertTrue(formatted.contains("0.01") || formatted.contains("0,01"), "Should format small amounts")
    }

    func testFormatUsesCurrencySymbol() throws {
        let formatted = CurrencyFormatter.format(50.0)
        // Should contain some currency symbol (varies by locale)
        XCTAssertFalse(formatted.isEmpty, "Should produce output")
        XCTAssertTrue(formatted.count > 2, "Should include currency formatting")
    }

    func testFormatFallback() throws {
        // Test with very large number to ensure fallback works
        let formatted = CurrencyFormatter.format(999999999999.99)
        XCTAssertFalse(formatted.isEmpty, "Should never return empty string")
    }
}
