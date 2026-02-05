import Foundation
import SwiftData

@Model
final class ReminderRule {
    var id: UUID
    var enabled: Bool
    var daysInterval: Int?
    var distanceIntervalKm: Double?

    var serviceType: ServiceTypeTemplate?
    var vehicle: Vehicle?

    init(
        id: UUID = UUID(),
        enabled: Bool = true,
        daysInterval: Int? = nil,
        distanceIntervalKm: Double? = nil
    ) {
        self.id = id
        self.enabled = enabled
        self.daysInterval = daysInterval
        self.distanceIntervalKm = distanceIntervalKm
    }
}
