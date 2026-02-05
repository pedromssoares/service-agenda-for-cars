import SwiftUI
import SwiftData

struct UpNextView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var notificationManager: NotificationManager
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    @Query(sort: \ServiceTypeTemplate.name) private var serviceTemplates: [ServiceTypeTemplate]
    @Query(sort: \ServiceEvent.date, order: .reverse) private var serviceEvents: [ServiceEvent]

    @State private var showingAddService = false
    @State private var showingUpdateOdometer = false
    @State private var pendingNotificationCount = 0

    var dueServices: [DueService] {
        ReminderCalculator.calculateDueServices(
            vehicles: vehicles,
            serviceTemplates: serviceTemplates,
            serviceEvents: serviceEvents
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if vehicles.isEmpty {
                    ContentUnavailableView(
                        "No Vehicles",
                        systemImage: "car",
                        description: Text("Add a vehicle in Settings to track service reminders")
                    )
                } else if dueServices.isEmpty {
                    ContentUnavailableView(
                        "All Caught Up!",
                        systemImage: "checkmark.circle",
                        description: Text("No services due at this time")
                    )
                } else {
                    List {
                        ForEach(dueServices) { dueService in
                            DueServiceRow(dueService: dueService)
                        }
                    }
                }
            }
            .navigationTitle("Up Next")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddService = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                if !vehicles.isEmpty {
                    ToolbarItem(placement: .secondaryAction) {
                        Button {
                            showingUpdateOdometer = true
                        } label: {
                            Label("Update Odometer", systemImage: "gauge")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddService) {
                AddServiceView()
            }
            .sheet(isPresented: $showingUpdateOdometer) {
                UpdateOdometerView()
            }
            .task {
                // Update notifications when view appears
                await notificationManager.scheduleNotifications(for: dueServices)
                pendingNotificationCount = await notificationManager.getPendingNotificationCount()
            }
            .onChange(of: dueServices.count) { _, _ in
                // Re-schedule when due services change
                Task {
                    await notificationManager.scheduleNotifications(for: dueServices)
                    pendingNotificationCount = await notificationManager.getPendingNotificationCount()
                }
            }
        }
    }
}

struct DueServiceRow: View {
    let dueService: DueService

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dueService.serviceType.name)
                        .font(.headline)

                    Text(dueService.vehicle.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                StatusBadge(status: dueService.status)
            }

            VStack(alignment: .leading, spacing: 4) {
                // Date-based reminder
                if let dueDate = dueService.dueDateByDate {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if dueService.isOverdueByDate {
                            Text("Overdue since \(dueDate, style: .date)")
                                .font(.caption)
                                .foregroundStyle(.red)
                        } else if let days = dueService.daysUntilDue {
                            Text("Due in \(days) days (\(dueDate, style: .date))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Distance-based reminder
                if let dueOdometer = dueService.dueOdometerKm {
                    HStack {
                        Image(systemName: "gauge")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if dueService.isOverdueByDistance {
                            Text("Overdue by \(DistanceFormatter.formatDistance(dueService.vehicle.currentOdometerKm - dueOdometer, unit: dueService.vehicle.unitPreference))")
                                .font(.caption)
                                .foregroundStyle(.red)
                        } else if let distanceUntil = dueService.distanceUntilDueKm {
                            Text("Due in \(DistanceFormatter.formatDistance(distanceUntil, unit: dueService.vehicle.unitPreference))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            if let lastDate = dueService.lastServiceDate {
                Text("Last service: \(lastDate, style: .date)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            } else {
                Text("Never serviced")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: DueService.DueStatus

    var body: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundStyle(.white)
            .cornerRadius(8)
    }

    var statusText: String {
        switch status {
        case .overdue: return "OVERDUE"
        case .dueSoon: return "DUE SOON"
        case .upcoming: return "UPCOMING"
        }
    }

    var backgroundColor: Color {
        switch status {
        case .overdue: return .red
        case .dueSoon: return .orange
        case .upcoming: return .blue
        }
    }
}

#Preview {
    UpNextView()
}
