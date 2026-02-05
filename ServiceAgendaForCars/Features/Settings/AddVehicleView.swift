import SwiftUI
import SwiftData

struct AddVehicleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var vehicleName: String = ""
    @State private var unitPreference: DistanceUnit = .kilometers

    var body: some View {
        NavigationStack {
            Form {
                Section("Vehicle Details") {
                    TextField("Vehicle Name", text: $vehicleName)
                        .autocorrectionDisabled()

                    Picker("Distance Unit", selection: $unitPreference) {
                        Text("Kilometers").tag(DistanceUnit.kilometers)
                        Text("Miles").tag(DistanceUnit.miles)
                    }
                }
            }
            .navigationTitle("Add Vehicle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addVehicle()
                    }
                    .disabled(vehicleName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func addVehicle() {
        let vehicle = Vehicle(
            name: vehicleName.trimmingCharacters(in: .whitespaces),
            unitPreference: unitPreference
        )
        modelContext.insert(vehicle)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddVehicleView()
}
