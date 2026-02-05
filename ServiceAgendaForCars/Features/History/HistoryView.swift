import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ServiceEvent.date, order: .reverse) private var serviceEvents: [ServiceEvent]

    @State private var showingAddService = false
    @State private var showingExportSheet = false
    @State private var csvDocument: CSVDocument?

    var body: some View {
        NavigationStack {
            Group {
                if serviceEvents.isEmpty {
                    ContentUnavailableView(
                        "No Service History",
                        systemImage: "wrench.and.screwdriver",
                        description: Text("Log your first service to get started")
                    )
                } else {
                    List {
                        ForEach(serviceEvents) { event in
                            ServiceEventRow(event: event)
                        }
                        .onDelete(perform: deleteEvents)
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddService = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                if !serviceEvents.isEmpty {
                    ToolbarItem(placement: .secondaryAction) {
                        Button {
                            exportToCSV()
                        } label: {
                            Label("Export CSV", systemImage: "square.and.arrow.up")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddService) {
                AddServiceView()
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
        }
    }

    private func deleteEvents(at offsets: IndexSet) {
        for index in offsets {
            let event = serviceEvents[index]
            modelContext.delete(event)
        }
        try? modelContext.save()
    }

    private func exportToCSV() {
        let csvContent = CSVExporter.generateCSV(from: serviceEvents)
        csvDocument = CSVDocument(csvContent: csvContent)
        showingExportSheet = true
    }
}

struct ServiceEventRow: View {
    let event: ServiceEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(event.serviceType?.name ?? "Unknown Service")
                    .font(.headline)
                Spacer()
                if let cost = event.cost {
                    Text(CurrencyFormatter.format(cost))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            HStack {
                Text(event.date, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let vehicle = event.vehicle {
                    Text("•")
                        .foregroundStyle(.tertiary)
                    Text(vehicle.name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("•")
                        .foregroundStyle(.tertiary)
                    Text(DistanceFormatter.formatDistance(
                        event.odometerKm,
                        unit: vehicle.unitPreference
                    ))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }

            if let notes = event.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HistoryView()
}
