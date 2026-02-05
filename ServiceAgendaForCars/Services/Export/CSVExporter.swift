import Foundation

struct CSVExporter {
    static func generateCSV(from serviceEvents: [ServiceEvent]) -> String {
        var csv = "vehicleName,serviceType,dateISO,odometerDisplayed,odometerUnit,cost,notes\n"

        // Sort by date (oldest first)
        let sortedEvents = serviceEvents.sorted { $0.date < $1.date }

        for event in sortedEvents {
            let vehicleName = event.vehicle?.name ?? "Unknown"
            let serviceType = event.serviceType?.name ?? "Unknown"
            let dateISO = ISO8601DateFormatter().string(from: event.date)

            let odometerUnit = event.vehicle?.unitPreference.abbreviation ?? "km"
            let odometerDisplayed: String
            if let vehicle = event.vehicle {
                let displayValue = DistanceFormatter.toDisplayValue(event.odometerKm, unit: vehicle.unitPreference)
                odometerDisplayed = String(format: "%.0f", displayValue)
            } else {
                odometerDisplayed = String(format: "%.0f", event.odometerKm)
            }

            let cost = event.cost != nil ? String(format: "%.2f", event.cost!) : ""
            let notes = escapeCsvValue(event.notes ?? "")

            let row = "\(escapeCsvValue(vehicleName)),\(escapeCsvValue(serviceType)),\(dateISO),\(odometerDisplayed),\(odometerUnit),\(cost),\(notes)\n"
            csv.append(row)
        }

        return csv
    }

    private static func escapeCsvValue(_ value: String) -> String {
        if value.isEmpty {
            return ""
        }

        // If value contains comma, quote, or newline, wrap in quotes and escape quotes
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            let escaped = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escaped)\""
        }

        return value
    }
}
