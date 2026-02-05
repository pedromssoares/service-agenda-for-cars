import SwiftUI
import SwiftData

@main
struct ServiceAgendaForCarsApp: App {
    let modelContainer: ModelContainer
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.scenePhase) private var scenePhase

    init() {
        do {
            let container = try ModelContainer(
                for: Vehicle.self,
                ServiceTypeTemplate.self,
                ServiceEvent.self,
                ReminderRule.self
            )
            modelContainer = container

            // Seed default data on first launch
            Task { @MainActor in
                await DataSeeder.seedDefaultServiceTemplates(modelContext: container.mainContext)
            }
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
        }
        .modelContainer(modelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                // Re-schedule notifications when app becomes active
                Task {
                    await rescheduleNotifications()
                }
            }
        }
    }

    @MainActor
    private func rescheduleNotifications() async {
        let context = modelContainer.mainContext

        let vehiclesDescriptor = FetchDescriptor<Vehicle>()
        let templatesDescriptor = FetchDescriptor<ServiceTypeTemplate>()
        let eventsDescriptor = FetchDescriptor<ServiceEvent>()

        guard let vehicles = try? context.fetch(vehiclesDescriptor),
              let templates = try? context.fetch(templatesDescriptor),
              let events = try? context.fetch(eventsDescriptor) else {
            return
        }

        let dueServices = ReminderCalculator.calculateDueServices(
            vehicles: vehicles,
            serviceTemplates: templates,
            serviceEvents: events
        )

        await notificationManager.scheduleNotifications(for: dueServices)
    }
}
