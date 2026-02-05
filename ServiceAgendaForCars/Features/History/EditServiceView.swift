import SwiftUI
import SwiftData

struct EditServiceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var notificationManager: NotificationManager

    @Bindable var serviceEvent: ServiceEvent

    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    @Query(sort: \ServiceTypeTemplate.name) private var serviceTemplates: [ServiceTypeTemplate]

    @State private var selectedVehicle: Vehicle?
    @State private var selectedServiceType: ServiceTypeTemplate?
    @State private var date: Date = Date()
    @State private var odometerDisplay: String = ""
    @State private var cost: String = ""
    @State private var notes: String = ""
    @State private var photos: [Data] = []
    @State private var showingDeleteConfirmation = false

    var enabledServiceTemplates: [ServiceTypeTemplate] {
        serviceTemplates.filter { $0.isEnabled }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle") {
                    Picker("Vehicle", selection: $selectedVehicle) {
                        Text("Select Vehicle").tag(nil as Vehicle?)
                        ForEach(vehicles) { vehicle in
                            Text(vehicle.name).tag(vehicle as Vehicle?)
                        }
                    }
                    .onChange(of: selectedVehicle) { _, newVehicle in
                        if let vehicle = newVehicle {
                            // Recalculate odometer display for new unit
                            let odometerValue = DistanceFormatter.toStoredValue(
                                Double(odometerDisplay) ?? 0,
                                unit: serviceEvent.vehicle?.unitPreference ?? .kilometers
                            )
                            let displayValue = DistanceFormatter.toDisplayValue(
                                odometerValue,
                                unit: vehicle.unitPreference
                            )
                            odometerDisplay = String(format: "%.0f", displayValue)
                        }
                    }
                }

                Section("Service Details") {
                    Picker("Service Type", selection: $selectedServiceType) {
                        Text("Select Service").tag(nil as ServiceTypeTemplate?)
                        ForEach(enabledServiceTemplates) { template in
                            Text(template.name).tag(template as ServiceTypeTemplate?)
                        }
                    }

                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    if let vehicle = selectedVehicle {
                        HStack {
                            Text("Odometer")
                            Spacer()
                            TextField("0", text: $odometerDisplay)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 120)
                            Text(vehicle.unitPreference.abbreviation)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Optional") {
                    HStack {
                        Text("Cost")
                        Spacer()
                        TextField("0.00", text: $cost)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 120)
                    }

                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    PhotoPicker(photos: $photos)
                }

                Section {
                    Button("Delete Service", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                }
            }
            .navigationTitle("Edit Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(!canSave)
                }
            }
            .alert("Delete Service?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteService()
                }
            } message: {
                Text("This action cannot be undone.")
            }
            .onAppear {
                loadServiceData()
            }
        }
    }

    private var canSave: Bool {
        guard selectedVehicle != nil,
              selectedServiceType != nil,
              let odometerValue = Double(odometerDisplay),
              odometerValue > 0 else {
            return false
        }
        return true
    }

    private func loadServiceData() {
        selectedVehicle = serviceEvent.vehicle
        selectedServiceType = serviceEvent.serviceType
        date = serviceEvent.date
        notes = serviceEvent.notes ?? ""
        photos = serviceEvent.photos

        if let vehicle = serviceEvent.vehicle {
            let displayValue = DistanceFormatter.toDisplayValue(
                serviceEvent.odometerKm,
                unit: vehicle.unitPreference
            )
            odometerDisplay = String(format: "%.0f", displayValue)
        } else {
            odometerDisplay = String(format: "%.0f", serviceEvent.odometerKm)
        }

        if let eventCost = serviceEvent.cost {
            cost = String(format: "%.2f", eventCost)
        }
    }

    private func saveChanges() {
        guard let vehicle = selectedVehicle,
              let serviceType = selectedServiceType,
              let odometerDisplayValue = Double(odometerDisplay) else {
            return
        }

        // Convert displayed odometer to stored km value
        let odometerKm = DistanceFormatter.toStoredValue(
            odometerDisplayValue,
            unit: vehicle.unitPreference
        )

        serviceEvent.vehicle = vehicle
        serviceEvent.serviceType = serviceType
        serviceEvent.date = date
        serviceEvent.odometerKm = odometerKm
        serviceEvent.cost = Double(cost)
        serviceEvent.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
        serviceEvent.setPhotos(photos)

        try? modelContext.save()

        // Re-schedule notifications after edit
        Task {
            await rescheduleNotifications()
        }

        dismiss()
    }

    private func deleteService() {
        modelContext.delete(serviceEvent)
        try? modelContext.save()

        // Re-schedule notifications after delete
        Task {
            await rescheduleNotifications()
        }

        dismiss()
    }

    @MainActor
    private func rescheduleNotifications() async {
        let vehiclesDescriptor = FetchDescriptor<Vehicle>()
        let templatesDescriptor = FetchDescriptor<ServiceTypeTemplate>()
        let eventsDescriptor = FetchDescriptor<ServiceEvent>()

        guard let vehicles = try? modelContext.fetch(vehiclesDescriptor),
              let templates = try? modelContext.fetch(templatesDescriptor),
              let events = try? modelContext.fetch(eventsDescriptor) else {
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
