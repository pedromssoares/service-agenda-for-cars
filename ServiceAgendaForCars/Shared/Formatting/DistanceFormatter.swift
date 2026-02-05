import Foundation

struct DistanceFormatter {
    /// Converts kilometers to miles
    static func kmToMiles(_ km: Double) -> Double {
        return km * 0.621371
    }

    /// Converts miles to kilometers
    static func milesToKm(_ miles: Double) -> Double {
        return miles * 1.60934
    }

    /// Converts stored km value to display value based on unit preference
    static func toDisplayValue(_ km: Double, unit: DistanceUnit) -> Double {
        switch unit {
        case .kilometers:
            return km
        case .miles:
            return kmToMiles(km)
        }
    }

    /// Converts display value to stored km value based on unit preference
    static func toStoredValue(_ displayValue: Double, unit: DistanceUnit) -> Double {
        switch unit {
        case .kilometers:
            return displayValue
        case .miles:
            return milesToKm(displayValue)
        }
    }

    /// Formats distance for display with unit
    static func formatDistance(_ km: Double, unit: DistanceUnit, decimals: Int = 0) -> String {
        let value = toDisplayValue(km, unit: unit)
        let formatted = String(format: "%.\(decimals)f", value)
        return "\(formatted) \(unit.abbreviation)"
    }
}
