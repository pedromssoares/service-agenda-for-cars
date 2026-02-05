import SwiftUI
import SwiftData
import Charts

struct CostAnalyticsView: View {
    @Query(sort: \ServiceEvent.date) private var serviceEvents: [ServiceEvent]
    @Query(sort: \Vehicle.name) private var vehicles: [Vehicle]

    @State private var selectedTimeframe: Timeframe = .all
    @State private var selectedVehicle: Vehicle?

    enum Timeframe: String, CaseIterable {
        case month = "This Month"
        case threeMonths = "3 Months"
        case year = "This Year"
        case all = "All Time"
    }

    var filteredEvents: [ServiceEvent] {
        var events = serviceEvents.filter { $0.cost != nil && $0.cost! > 0 }

        // Filter by vehicle
        if let vehicle = selectedVehicle {
            events = events.filter { $0.vehicle?.id == vehicle.id }
        }

        // Filter by timeframe
        let calendar = Calendar.current
        let now = Date()

        switch selectedTimeframe {
        case .month:
            if let startDate = calendar.date(byAdding: .month, value: -1, to: now) {
                events = events.filter { $0.date >= startDate }
            }
        case .threeMonths:
            if let startDate = calendar.date(byAdding: .month, value: -3, to: now) {
                events = events.filter { $0.date >= startDate }
            }
        case .year:
            if let startDate = calendar.date(byAdding: .year, value: -1, to: now) {
                events = events.filter { $0.date >= startDate }
            }
        case .all:
            break
        }

        return events
    }

    var totalCost: Double {
        filteredEvents.compactMap { $0.cost }.reduce(0, +)
    }

    var averageCost: Double {
        guard !filteredEvents.isEmpty else { return 0 }
        return totalCost / Double(filteredEvents.count)
    }

    var costByServiceType: [ServiceTypeCost] {
        let grouped = Dictionary(grouping: filteredEvents) { $0.serviceType?.name ?? "Unknown" }
        return grouped.map { name, events in
            let total = events.compactMap { $0.cost }.reduce(0, +)
            let count = events.count
            return ServiceTypeCost(name: name, total: total, count: count)
        }.sorted { $0.total > $1.total }
    }

    var costByMonth: [MonthCost] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: filteredEvents) { event -> Date in
            let components = calendar.dateComponents([.year, .month], from: event.date)
            return calendar.date(from: components) ?? event.date
        }

        return grouped.map { date, events in
            let total = events.compactMap { $0.cost }.reduce(0, +)
            return MonthCost(month: date, total: total)
        }.sorted { $0.month < $1.month }
    }

    var body: some View {
        List {
            Section {
                Picker("Timeframe", selection: $selectedTimeframe) {
                    ForEach(Timeframe.allCases, id: \.self) { timeframe in
                        Text(timeframe.rawValue).tag(timeframe)
                    }
                }
                .pickerStyle(.segmented)

                if vehicles.count > 1 {
                    Picker("Vehicle", selection: $selectedVehicle) {
                        Text("All Vehicles").tag(nil as Vehicle?)
                        ForEach(vehicles) { vehicle in
                            Text(vehicle.name).tag(vehicle as Vehicle?)
                        }
                    }
                }
            }

            if filteredEvents.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No Cost Data",
                        systemImage: "chart.bar",
                        description: Text("Add service costs to see analytics")
                    )
                }
            } else {
                // Summary stats
                Section("Summary") {
                    HStack {
                        Text("Total Spent")
                        Spacer()
                        Text(CurrencyFormatter.format(totalCost))
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }

                    HStack {
                        Text("Total Services")
                        Spacer()
                        Text("\(filteredEvents.count)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Average Cost")
                        Spacer()
                        Text(CurrencyFormatter.format(averageCost))
                            .foregroundStyle(.secondary)
                    }
                }

                // Cost over time chart
                if costByMonth.count > 1 {
                    Section("Cost Trend") {
                        Chart(costByMonth) { item in
                            LineMark(
                                x: .value("Month", item.month, unit: .month),
                                y: .value("Cost", item.total)
                            )
                            .foregroundStyle(.blue)

                            AreaMark(
                                x: .value("Month", item.month, unit: .month),
                                y: .value("Cost", item.total)
                            )
                            .foregroundStyle(.blue.opacity(0.2))
                        }
                        .frame(height: 200)
                        .chartYAxisLabel("Cost")
                    }
                }

                // Cost by service type
                Section("By Service Type") {
                    Chart(costByServiceType) { item in
                        BarMark(
                            x: .value("Cost", item.total),
                            y: .value("Service", item.name)
                        )
                        .foregroundStyle(.blue)
                        .annotation(position: .trailing) {
                            Text(CurrencyFormatter.format(item.total))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: CGFloat(costByServiceType.count * 40))
                    .chartXAxisLabel("Total Cost")
                }

                // Breakdown list
                Section("Breakdown") {
                    ForEach(costByServiceType) { item in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(item.name)
                                    .font(.headline)
                                Spacer()
                                Text(CurrencyFormatter.format(item.total))
                                    .font(.headline)
                                    .foregroundStyle(.blue)
                            }

                            HStack {
                                Text("\(item.count) services")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("Avg: \(CurrencyFormatter.format(item.total / Double(item.count)))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .navigationTitle("Cost Analytics")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ServiceTypeCost: Identifiable {
    let id = UUID()
    let name: String
    let total: Double
    let count: Int
}

struct MonthCost: Identifiable {
    let id = UUID()
    let month: Date
    let total: Double
}

#Preview {
    NavigationStack {
        CostAnalyticsView()
    }
}
