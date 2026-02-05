import Foundation
import SwiftData

@Model
final class ServiceEvent {
    var id: UUID
    var date: Date
    var odometerKm: Double
    var cost: Double?
    var notes: String?

    var vehicle: Vehicle?
    var serviceType: ServiceTypeTemplate?

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        odometerKm: Double,
        cost: Double? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.date = date
        self.odometerKm = odometerKm
        self.cost = cost
        self.notes = notes
    }
}
