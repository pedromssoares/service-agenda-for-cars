import SwiftUI
import SwiftData

struct VehicleRemindersView: View {
    @Environment(\.modelContext) private var modelContext
    let vehicle: Vehicle

    @Query(sort: \ServiceTypeTemplate.name) private var allServiceTemplates: [ServiceTypeTemplate]

    var enabledServiceTemplates: [ServiceTypeTemplate] {
        allServiceTemplates.filter { $0.isEnabled }
    }

    var body: some View {
        List {
            Section {
                Text("Customize reminder intervals for \(vehicle.name). Leave empty to use default intervals.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ForEach(enabledServiceTemplates) { template in
                VehicleReminderRow(vehicle: vehicle, template: template)
            }
        }
        .navigationTitle("Service Reminders")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct VehicleReminderRow: View {
    @Environment(\.modelContext) private var modelContext
    let vehicle: Vehicle
    let template: ServiceTypeTemplate

    @State private var reminderRule: ReminderRule?
    @State private var showingEditSheet = false

    var body: some View {
        Button {
            showingEditSheet = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    if let rule = reminderRule {
                        HStack {
                            if let days = rule.daysInterval {
                                Text("\(days) days")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }

                            if let km = rule.distanceIntervalKm {
                                if rule.daysInterval != nil {
                                    Text("or")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                Text("\(Int(km)) km")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }

                            if rule.daysInterval == nil && rule.distanceIntervalKm == nil {
                                Text("Using defaults")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        // Show default intervals
                        HStack {
                            if let days = template.defaultIntervalDays {
                                Text("\(days) days")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            if let km = template.defaultIntervalDistanceKm {
                                if template.defaultIntervalDays != nil {
                                    Text("or")
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                }
                                Text("\(Int(km)) km")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Text("(default)")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditVehicleReminderView(vehicle: vehicle, template: template, existingRule: reminderRule)
        }
        .onAppear {
            loadReminderRule()
        }
        .onChange(of: showingEditSheet) { _, isShowing in
            if !isShowing {
                loadReminderRule()
            }
        }
    }

    private func loadReminderRule() {
        let rules = vehicle.reminderRules ?? []
        reminderRule = rules.first { $0.serviceType?.id == template.id }
    }
}

struct EditVehicleReminderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let vehicle: Vehicle
    let template: ServiceTypeTemplate
    let existingRule: ReminderRule?

    @State private var useCustomIntervals = false
    @State private var hasDateInterval = false
    @State private var intervalDays: String = ""
    @State private var hasDistanceInterval = false
    @State private var intervalKm: String = ""
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Service Type") {
                    Text(template.name)
                        .font(.headline)
                }

                Section("Default Intervals") {
                    if let days = template.defaultIntervalDays {
                        HStack {
                            Text("Date")
                            Spacer()
                            Text("Every \(days) days")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let km = template.defaultIntervalDistanceKm {
                        HStack {
                            Text("Distance")
                            Spacer()
                            Text("Every \(Int(km)) km")
                                .foregroundStyle(.secondary)
                        }
                    }

                    if template.defaultIntervalDays == nil && template.defaultIntervalDistanceKm == nil {
                        Text("No default intervals set")
                            .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Toggle("Use custom intervals for \(vehicle.name)", isOn: $useCustomIntervals)
                } header: {
                    Text("Custom Intervals")
                } footer: {
                    Text("Override default intervals specifically for this vehicle.")
                }

                if useCustomIntervals {
                    Section("Custom Reminder Intervals") {
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
                }

                if existingRule != nil {
                    Section {
                        Button("Remove Custom Intervals", role: .destructive) {
                            showingDeleteConfirmation = true
                        }
                    }
                }
            }
            .navigationTitle("Customize Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveReminderRule()
                    }
                }
            }
            .alert("Remove Custom Intervals?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Remove", role: .destructive) {
                    deleteReminderRule()
                }
            } message: {
                Text("This will revert to using default intervals.")
            }
            .onAppear {
                loadData()
            }
        }
    }

    private func loadData() {
        if let rule = existingRule {
            useCustomIntervals = true
            hasDateInterval = rule.daysInterval != nil
            intervalDays = rule.daysInterval.map { String($0) } ?? ""
            hasDistanceInterval = rule.distanceIntervalKm != nil
            intervalKm = rule.distanceIntervalKm.map { String(Int($0)) } ?? ""
        }
    }

    private func saveReminderRule() {
        if !useCustomIntervals {
            // Delete existing rule if unchecking custom
            if let rule = existingRule {
                modelContext.delete(rule)
                try? modelContext.save()
            }
            dismiss()
            return
        }

        let days = hasDateInterval ? Int(intervalDays) : nil
        let km = hasDistanceInterval ? Double(intervalKm) : nil

        if let rule = existingRule {
            // Update existing
            rule.daysInterval = days
            rule.distanceIntervalKm = km
        } else {
            // Create new
            let rule = ReminderRule(
                enabled: true,
                daysInterval: days,
                distanceIntervalKm: km
            )
            rule.vehicle = vehicle
            rule.serviceType = template
            modelContext.insert(rule)
        }

        try? modelContext.save()
        dismiss()
    }

    private func deleteReminderRule() {
        if let rule = existingRule {
            modelContext.delete(rule)
            try? modelContext.save()
        }
        dismiss()
    }
}

#Preview {
    NavigationStack {
        Text("Preview placeholder")
    }
}
