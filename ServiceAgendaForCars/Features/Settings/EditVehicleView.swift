import SwiftUI
import SwiftData

struct EditVehicleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var vehicle: Vehicle
    @State private var odometerDisplay: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle Details") {
                    TextField("Vehicle Name", text: $vehicle.name)
                        .autocorrectionDisabled()

                    Picker("Distance Unit", selection: $vehicle.unitPreference) {
                        Text("Kilometers").tag(DistanceUnit.kilometers)
                        Text("Miles").tag(DistanceUnit.miles)
                    }
                }

                Section("Current Odometer") {
                    HStack {
                        TextField("Odometer", text: $odometerDisplay)
                            .keyboardType(.decimalPad)
                        Text(vehicle.unitPreference.abbreviation)
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Button("Delete Vehicle", role: .destructive) {
                        deleteVehicle()
                    }
                }
            }
            .navigationTitle("Edit Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveChanges()
                    }
                }
            }
            .onAppear {
                // Initialize odometer display value
                let displayValue = DistanceFormatter.toDisplayValue(
                    vehicle.currentOdometerKm,
                    unit: vehicle.unitPreference
                )
                odometerDisplay = String(format: "%.0f", displayValue)
            }
        }
    }

    private func saveChanges() {
        // Update odometer if valid
        if let odometerValue = Double(odometerDisplay), odometerValue >= 0 {
            vehicle.currentOdometerKm = DistanceFormatter.toStoredValue(
                odometerValue,
                unit: vehicle.unitPreference
            )
        }

        try? modelContext.save()
        dismiss()
    }

    private func deleteVehicle() {
        modelContext.delete(vehicle)
        try? modelContext.save()
        dismiss()
    }
}
