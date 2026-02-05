import Foundation
import SwiftData

@Model
final class Vehicle {
    var id: UUID
    var name: String
    var unitPreference: DistanceUnit
    var currentOdometerKm: Double
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \ServiceEvent.vehicle)
    var serviceEvents: [ServiceEvent]?

    @Relationship(deleteRule: .cascade, inverse: \ReminderRule.vehicle)
    var reminderRules: [ReminderRule]?

    init(
        id: UUID = UUID(),
        name: String,
        unitPreference: DistanceUnit = .kilometers,
        currentOdometerKm: Double = 0,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.unitPreference = unitPreference
        self.currentOdometerKm = currentOdometerKm
        self.createdAt = createdAt
    }
}

enum DistanceUnit: String, Codable {
    case kilometers
    case miles

    var abbreviation: String {
        switch self {
        case .kilometers: return "km"
        case .miles: return "mi"
        }
    }
}
