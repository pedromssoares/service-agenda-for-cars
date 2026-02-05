import SwiftUI
import SwiftData

struct UpdateOdometerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]

    @State private var selectedVehicle: Vehicle?
    @State private var odometerDisplay: String = ""

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
                            // Pre-fill with current odometer
                            let displayValue = DistanceFormatter.toDisplayValue(
                                vehicle.currentOdometerKm,
                                unit: vehicle.unitPreference
                            )
                            odometerDisplay = String(format: "%.0f", displayValue)
                        }
                    }
                }

                if let vehicle = selectedVehicle {
                    Section("Current Odometer") {
                        HStack {
                            TextField("Odometer", text: $odometerDisplay)
                                .keyboardType(.decimalPad)
                            Text(vehicle.unitPreference.abbreviation)
                                .foregroundStyle(.secondary)
                        }

                        Text("Current: \(DistanceFormatter.formatDistance(vehicle.currentOdometerKm, unit: vehicle.unitPreference))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Update Odometer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveOdometer()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                // Auto-select vehicle if only one exists
                if vehicles.count == 1, let vehicle = vehicles.first {
                    selectedVehicle = vehicle
                    let displayValue = DistanceFormatter.toDisplayValue(
                        vehicle.currentOdometerKm,
                        unit: vehicle.unitPreference
                    )
                    odometerDisplay = String(format: "%.0f", displayValue)
                }
            }
        }
    }

    private var canSave: Bool {
        guard selectedVehicle != nil,
              let odometerValue = Double(odometerDisplay),
              odometerValue >= 0 else {
            return false
        }
        return true
    }

    private func saveOdometer() {
        guard let vehicle = selectedVehicle,
              let odometerDisplayValue = Double(odometerDisplay) else {
            return
        }

        // Convert displayed odometer to stored km value
        let odometerKm = DistanceFormatter.toStoredValue(
            odometerDisplayValue,
            unit: vehicle.unitPreference
        )

        vehicle.currentOdometerKm = odometerKm
        try? modelContext.save()

        dismiss()
    }
}

#Preview {
    UpdateOdometerView()
}
