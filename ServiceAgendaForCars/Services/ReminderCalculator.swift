import Foundation
import SwiftData

struct DueService: Identifiable {
    let id: UUID
    let vehicle: Vehicle
    let serviceType: ServiceTypeTemplate
    let lastServiceDate: Date?
    let lastServiceOdometerKm: Double?
    let dueDateByDate: Date?
    let dueOdometerKm: Double?
    let status: DueStatus

    enum DueStatus: Comparable {
        case overdue
        case dueSoon
        case upcoming

        var priority: Int {
            switch self {
            case .overdue: return 0
            case .dueSoon: return 1
            case .upcoming: return 2
            }
        }

        static func < (lhs: DueStatus, rhs: DueStatus) -> Bool {
            lhs.priority < rhs.priority
        }
    }

    var isOverdueByDate: Bool {
        guard let dueDate = dueDateByDate else { return false }
        return dueDate < Date()
    }

    var isOverdueByDistance: Bool {
        guard let dueOdometer = dueOdometerKm else { return false }
        return vehicle.currentOdometerKm >= dueOdometer
    }

    var daysUntilDue: Int? {
        guard let dueDate = dueDateByDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day
    }

    var distanceUntilDueKm: Double? {
        guard let dueOdometer = dueOdometerKm else { return nil }
        return dueOdometer - vehicle.currentOdometerKm
    }
}

@MainActor
class ReminderCalculator {

    static func calculateDueServices(
        vehicles: [Vehicle],
        serviceTemplates: [ServiceTypeTemplate],
        serviceEvents: [ServiceEvent]
    ) -> [DueService] {
        var dueServices: [DueService] = []

        for vehicle in vehicles {
            let vehicleEvents = serviceEvents.filter { $0.vehicle?.id == vehicle.id }

            for template in serviceTemplates where template.isEnabled {
                // Find the last service of this type for this vehicle
                let lastEvent = vehicleEvents
                    .filter { $0.serviceType?.id == template.id }
                    .sorted { $0.date > $1.date }
                    .first

                // Calculate due date based on time interval
                var dueDateByDate: Date?
                if let days = template.defaultIntervalDays {
                    let baseDate = lastEvent?.date ?? vehicle.createdAt
                    dueDateByDate = Calendar.current.date(byAdding: .day, value: days, to: baseDate)
                }

                // Calculate due odometer based on distance interval
                var dueOdometerKm: Double?
                if let intervalKm = template.defaultIntervalDistanceKm {
                    let baseOdometer = lastEvent?.odometerKm ?? 0
                    dueOdometerKm = baseOdometer + intervalKm
                }

                // Determine status
                let status = determineStatus(
                    dueDateByDate: dueDateByDate,
                    dueOdometerKm: dueOdometerKm,
                    currentOdometerKm: vehicle.currentOdometerKm
                )

                let dueService = DueService(
                    id: UUID(),
                    vehicle: vehicle,
                    serviceType: template,
                    lastServiceDate: lastEvent?.date,
                    lastServiceOdometerKm: lastEvent?.odometerKm,
                    dueDateByDate: dueDateByDate,
                    dueOdometerKm: dueOdometerKm,
                    status: status
                )

                dueServices.append(dueService)
            }
        }

        // Sort by status (overdue first) then by urgency
        return dueServices.sorted { lhs, rhs in
            if lhs.status != rhs.status {
                return lhs.status < rhs.status
            }

            // Within same status, sort by most urgent first
            let lhsDays = lhs.daysUntilDue ?? Int.max
            let rhsDays = rhs.daysUntilDue ?? Int.max
            return lhsDays < rhsDays
        }
    }

    private static func determineStatus(
        dueDateByDate: Date?,
        dueOdometerKm: Double?,
        currentOdometerKm: Double
    ) -> DueService.DueStatus {
        let now = Date()

        // Check if overdue by date
        if let dueDate = dueDateByDate, dueDate < now {
            return .overdue
        }

        // Check if overdue by distance
        if let dueOdometer = dueOdometerKm, currentOdometerKm >= dueOdometer {
            return .overdue
        }

        // Check if due soon (within 30 days or 1000 km)
        if let dueDate = dueDateByDate {
            let daysUntilDue = Calendar.current.dateComponents([.day], from: now, to: dueDate).day ?? Int.max
            if daysUntilDue <= 30 {
                return .dueSoon
            }
        }

        if let dueOdometer = dueOdometerKm {
            let distanceUntilDue = dueOdometer - currentOdometerKm
            if distanceUntilDue <= 1000 {
                return .dueSoon
            }
        }

        return .upcoming
    }
}
