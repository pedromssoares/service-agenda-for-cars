import SwiftUI
import SwiftData

struct AddServiceView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    @Query(sort: \ServiceTypeTemplate.name) private var serviceTemplates: [ServiceTypeTemplate]

    @State private var selectedVehicle: Vehicle?
    @State private var selectedServiceType: ServiceTypeTemplate?
    @State private var date: Date = Date()
    @State private var odometerDisplay: String = ""
    @State private var cost: String = ""
    @State private var notes: String = ""
    @State private var photos: [Data] = []

    var enabledServiceTemplates: [ServiceTypeTemplate] {
        serviceTemplates.filter { $0.isEnabled }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle") {
                    if vehicles.isEmpty {
                        Text("No vehicles available. Add one in Settings.")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Vehicle", selection: $selectedVehicle) {
                            Text("Select Vehicle").tag(nil as Vehicle?)
                            ForEach(vehicles) { vehicle in
                                Text(vehicle.name).tag(vehicle as Vehicle?)
                            }
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
            }
            .navigationTitle("Log Service")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveService()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                // Auto-select vehicle if only one exists
                if vehicles.count == 1 {
                    selectedVehicle = vehicles.first
                }
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

    private func saveService() {
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

        let serviceEvent = ServiceEvent(
            date: date,
            odometerKm: odometerKm,
            cost: Double(cost),
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes
        )

        serviceEvent.vehicle = vehicle
        serviceEvent.serviceType = serviceType
        serviceEvent.setPhotos(photos)

        modelContext.insert(serviceEvent)
        try? modelContext.save()

        dismiss()
    }
}

#Preview {
    AddServiceView()
}
