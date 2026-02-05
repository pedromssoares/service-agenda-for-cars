import SwiftUI
import SwiftData

struct EditServiceTypeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var template: ServiceTypeTemplate

    @State private var name: String = ""
    @State private var hasDateInterval = false
    @State private var intervalDays: String = ""
    @State private var hasDistanceInterval = false
    @State private var intervalKm: String = ""
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Service Type") {
                    if template.isCustom {
                        TextField("Name", text: $name)
                            .autocorrectionDisabled()
                    } else {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(template.name)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Reminder Intervals") {
                    if template.isCustom {
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
                    } else {
                        HStack {
                            Text("Date interval")
                            Spacer()
                            if let days = template.defaultIntervalDays {
                                Text("\(days) days")
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("None")
                                    .foregroundStyle(.tertiary)
                            }
                        }

                        HStack {
                            Text("Distance interval")
                            Spacer()
                            if let km = template.defaultIntervalDistanceKm {
                                Text("\(Int(km)) km")
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("None")
                                    .foregroundStyle(.tertiary)
                            }
                        }

                        Text("Default service types cannot be edited. Create a custom type instead.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Status") {
                    Toggle("Enabled", isOn: $template.isEnabled)

                    Text(template.isEnabled ? "This service type is available when logging services." : "This service type is hidden from service logging.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if template.isCustom {
                    Section {
                        Button("Delete Service Type", role: .destructive) {
                            showingDeleteConfirmation = true
                        }
                    }
                }
            }
            .navigationTitle(template.isCustom ? "Edit Service Type" : "Service Type")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveChanges()
                    }
                }
            }
            .alert("Delete Service Type?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteServiceType()
                }
            } message: {
                Text("This will not delete existing service records, but they will show as 'Unknown Service'.")
            }
            .onAppear {
                loadData()
            }
        }
    }

    private func loadData() {
        name = template.name
        hasDateInterval = template.defaultIntervalDays != nil
        intervalDays = template.defaultIntervalDays.map { String($0) } ?? ""
        hasDistanceInterval = template.defaultIntervalDistanceKm != nil
        intervalKm = template.defaultIntervalDistanceKm.map { String(Int($0)) } ?? ""
    }

    private func saveChanges() {
        if template.isCustom {
            template.name = name.trimmingCharacters(in: .whitespaces)
            template.defaultIntervalDays = hasDateInterval ? Int(intervalDays) : nil
            template.defaultIntervalDistanceKm = hasDistanceInterval ? Double(intervalKm) : nil
        }

        try? modelContext.save()
        dismiss()
    }

    private func deleteServiceType() {
        modelContext.delete(template)
        try? modelContext.save()
        dismiss()
    }
}
