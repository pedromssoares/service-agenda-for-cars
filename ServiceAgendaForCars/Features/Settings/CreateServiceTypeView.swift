import SwiftUI
import SwiftData

struct CreateServiceTypeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var hasDateInterval = false
    @State private var intervalDays: String = ""
    @State private var hasDistanceInterval = false
    @State private var intervalKm: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Service Type") {
                    TextField("Name (e.g., Wiper Blades)", text: $name)
                        .autocorrectionDisabled()
                }

                Section("Reminder Intervals") {
                    Toggle("Date-based reminder", isOn: $hasDateInterval)

                    if hasDateInterval {
                        HStack {
                            Text("Every")
                            TextField("Days", text: $intervalDays)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 100)
                            Text("days")
                                .foregroundStyle(.secondary)
                        }
                    }

                    Toggle("Distance-based reminder", isOn: $hasDistanceInterval)

                    if hasDistanceInterval {
                        HStack {
                            Text("Every")
                            TextField("Kilometers", text: $intervalKm)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(maxWidth: 100)
                            Text("km")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section {
                    Text("You can set reminders later for individual vehicles if needed.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Service Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createServiceType()
                    }
                    .disabled(!canCreate)
                }
            }
        }
    }

    private var canCreate: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func createServiceType() {
        let days = hasDateInterval ? Int(intervalDays) : nil
        let km = hasDistanceInterval ? Double(intervalKm) : nil

        let template = ServiceTypeTemplate(
            name: name.trimmingCharacters(in: .whitespaces),
            defaultIntervalDays: days,
            defaultIntervalDistanceKm: km,
            isEnabled: true,
            isCustom: true
        )

        modelContext.insert(template)
        try? modelContext.save()

        dismiss()
    }
}

#Preview {
    CreateServiceTypeView()
}
