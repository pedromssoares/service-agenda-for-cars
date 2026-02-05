import SwiftUI
import SwiftData

struct ManageServiceTypesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ServiceTypeTemplate.name) private var serviceTemplates: [ServiceTypeTemplate]

    @State private var showingCreateSheet = false
    @State private var selectedTemplate: ServiceTypeTemplate?

    var defaultTemplates: [ServiceTypeTemplate] {
        serviceTemplates.filter { !$0.isCustom }
    }

    var customTemplates: [ServiceTypeTemplate] {
        serviceTemplates.filter { $0.isCustom }
    }

    var body: some View {
        List {
            Section("Default Service Types") {
                ForEach(defaultTemplates) { template in
                    ServiceTypeRow(template: template) {
                        selectedTemplate = template
                    }
                }
            }

            Section("Custom Service Types") {
                if customTemplates.isEmpty {
                    Text("No custom service types")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(customTemplates) { template in
                        ServiceTypeRow(template: template) {
                            selectedTemplate = template
                        }
                    }
                    .onDelete(perform: deleteCustomTypes)
                }

                Button {
                    showingCreateSheet = true
                } label: {
                    Label("Add Custom Type", systemImage: "plus.circle.fill")
                }
            }
        }
        .navigationTitle("Service Types")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingCreateSheet) {
            CreateServiceTypeView()
        }
        .sheet(item: $selectedTemplate) { template in
            EditServiceTypeView(template: template)
        }
    }

    private func deleteCustomTypes(at offsets: IndexSet) {
        for index in offsets {
            let template = customTemplates[index]
            modelContext.delete(template)
        }
        try? modelContext.save()
    }
}

struct ServiceTypeRow: View {
    @Bindable var template: ServiceTypeTemplate
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(template.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

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

                        if template.defaultIntervalDays == nil && template.defaultIntervalDistanceKm == nil {
                            Text("No default interval")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                Spacer()

                Toggle("", isOn: $template.isEnabled)
                    .labelsHidden()
                    .onChange(of: template.isEnabled) { _, _ in
                        try? template.modelContext?.save()
                    }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ManageServiceTypesView()
    }
}
