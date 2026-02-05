import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var notificationManager: NotificationManager
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    @Query(sort: \ServiceEvent.date) private var serviceEvents: [ServiceEvent]

    @State private var showingAddVehicle = false
    @State private var selectedVehicle: Vehicle?
    @State private var pendingNotificationCount = 0
    @State private var showingExportSheet = false
    @State private var csvDocument: CSVDocument?

    var body: some View {
        NavigationStack {
            List {
                Section("Vehicles") {
                    if vehicles.isEmpty {
                        Text("No vehicles added yet")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(vehicles) { vehicle in
                            Button {
                                selectedVehicle = vehicle
                            } label: {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(vehicle.name)
                                            .foregroundStyle(.primary)
                                        Text("Distance: \(vehicle.unitPreference.rawValue.capitalized)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                    }

                    Button {
                        showingAddVehicle = true
                    } label: {
                        Label("Add Vehicle", systemImage: "plus.circle.fill")
                    }
                }

                Section("Notifications") {
                    HStack {
                        Text("Status")
                        Spacer()
                        if notificationManager.permissionGranted {
                            Label("Enabled", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(ColorTheme.success)
                                .font(.subheadline)
                        } else {
                            Label("Disabled", systemImage: "xmark.circle.fill")
                                .foregroundStyle(ColorTheme.error)
                                .font(.subheadline)
                        }
                    }

                    HStack {
                        Text("Pending Reminders")
                        Spacer()
                        Text("\(pendingNotificationCount)")
                            .foregroundStyle(.secondary)
                    }

                    if !notificationManager.permissionGranted {
                        Button {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            Text("Enable in System Settings")
                        }
                    }
                }

                Section("Maintenance") {
                    NavigationLink {
                        ManageServiceTypesView()
                    } label: {
                        Label("Service Types", systemImage: "wrench.and.screwdriver")
                    }

                    if !serviceEvents.isEmpty {
                        NavigationLink {
                            CostAnalyticsView()
                        } label: {
                            Label("Cost Analytics", systemImage: "chart.bar")
                        }
                    }
                }

                Section("Data") {
                    if !serviceEvents.isEmpty {
                        Button {
                            exportToCSV()
                        } label: {
                            Label("Export Service History", systemImage: "square.and.arrow.up")
                        }

                        HStack {
                            Text("Total Services")
                            Spacer()
                            Text("\(serviceEvents.count)")
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("No service history to export")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    HStack {
                        Text("App Version")
                        Spacer()
                        Text("1.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingAddVehicle) {
                AddVehicleView()
            }
            .sheet(item: $selectedVehicle) { vehicle in
                EditVehicleView(vehicle: vehicle)
            }
            .fileExporter(
                isPresented: $showingExportSheet,
                document: csvDocument,
                contentType: .commaSeparatedText,
                defaultFilename: "service-history-\(Date().ISO8601Format()).csv"
            ) { result in
                switch result {
                case .success(let url):
                    print("CSV exported to: \(url)")
                case .failure(let error):
                    print("Export error: \(error)")
                }
            }
            .task {
                await notificationManager.checkPermissionStatus()
                pendingNotificationCount = await notificationManager.getPendingNotificationCount()
            }
            .onAppear {
                Task {
                    await notificationManager.checkPermissionStatus()
                    pendingNotificationCount = await notificationManager.getPendingNotificationCount()
                }
            }
        }
    }

    private func exportToCSV() {
        let csvContent = CSVExporter.generateCSV(from: serviceEvents)
        csvDocument = CSVDocument(csvContent: csvContent)
        showingExportSheet = true
    }
}

#Preview {
    SettingsView()
}
