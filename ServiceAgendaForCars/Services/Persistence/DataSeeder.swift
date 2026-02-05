import Foundation
import SwiftData

@MainActor
class DataSeeder {
    static func seedDefaultServiceTemplates(modelContext: ModelContext) async {
        // Check if templates already exist
        let descriptor = FetchDescriptor<ServiceTypeTemplate>()
        let existingTemplates = try? modelContext.fetch(descriptor)

        if let templates = existingTemplates, !templates.isEmpty {
            // Already seeded
            return
        }

        // Create default service type templates
        let defaultTemplates = [
            ServiceTypeTemplate(
                name: "Oil Change",
                defaultIntervalDays: 180,
                defaultIntervalDistanceKm: 8000,
                isEnabled: true
            ),
            ServiceTypeTemplate(
                name: "Tire Rotation",
                defaultIntervalDays: 180,
                defaultIntervalDistanceKm: 10000,
                isEnabled: true
            ),
            ServiceTypeTemplate(
                name: "Air Filter Replacement",
                defaultIntervalDays: 365,
                defaultIntervalDistanceKm: 20000,
                isEnabled: true
            ),
            ServiceTypeTemplate(
                name: "Brake Inspection",
                defaultIntervalDays: 365,
                defaultIntervalDistanceKm: 15000,
                isEnabled: true
            ),
            ServiceTypeTemplate(
                name: "Battery Check",
                defaultIntervalDays: 730,
                defaultIntervalDistanceKm: nil,
                isEnabled: true
            ),
            ServiceTypeTemplate(
                name: "Coolant Flush",
                defaultIntervalDays: 730,
                defaultIntervalDistanceKm: 50000,
                isEnabled: true
            ),
            ServiceTypeTemplate(
                name: "Transmission Service",
                defaultIntervalDays: 730,
                defaultIntervalDistanceKm: 60000,
                isEnabled: true
            ),
            ServiceTypeTemplate(
                name: "Spark Plugs",
                defaultIntervalDays: 1095,
                defaultIntervalDistanceKm: 50000,
                isEnabled: true
            )
        ]

        for template in defaultTemplates {
            modelContext.insert(template)
        }

        try? modelContext.save()
    }
}
