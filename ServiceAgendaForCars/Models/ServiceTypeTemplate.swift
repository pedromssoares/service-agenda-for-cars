import Foundation
import SwiftData

@Model
final class ServiceTypeTemplate {
    var id: UUID
    var name: String
    var defaultIntervalDays: Int?
    var defaultIntervalDistanceKm: Double?
    var isEnabled: Bool

    @Relationship(deleteRule: .nullify, inverse: \ServiceEvent.serviceType)
    var serviceEvents: [ServiceEvent]?

    @Relationship(deleteRule: .cascade, inverse: \ReminderRule.serviceType)
    var reminderRules: [ReminderRule]?

    init(
        id: UUID = UUID(),
        name: String,
        defaultIntervalDays: Int? = nil,
        defaultIntervalDistanceKm: Double? = nil,
        isEnabled: Bool = true
    ) {
        self.id = id
        self.name = name
        self.defaultIntervalDays = defaultIntervalDays
        self.defaultIntervalDistanceKm = defaultIntervalDistanceKm
        self.isEnabled = isEnabled
    }
}
