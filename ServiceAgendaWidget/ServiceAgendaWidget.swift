import WidgetKit
import SwiftUI
import SwiftData

struct ServiceAgendaWidget: Widget {
    let kind: String = "ServiceAgendaWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ServiceAgendaWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Next Service")
        .description("See your next due service at a glance")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> ServiceEntry {
        ServiceEntry(date: Date(), nextService: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (ServiceEntry) -> ()) {
        let entry = ServiceEntry(date: Date(), nextService: nil)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ServiceEntry>) -> ()) {
        let nextService = getNextDueService()
        let entry = ServiceEntry(date: Date(), nextService: nextService)

        // Update widget every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func getNextDueService() -> NextServiceInfo? {
        guard let modelContainer = try? ModelContainer(
            for: Vehicle.self, ServiceTypeTemplate.self, ServiceEvent.self, ReminderRule.self,
            configurations: ModelConfiguration(groupContainer: .identifier("group.com.serviceagenda.shared"))
        ) else {
            return nil
        }

        let context = modelContainer.mainContext

        let vehicleDescriptor = FetchDescriptor<Vehicle>(sortBy: [SortDescriptor(\.createdAt)])
        let templateDescriptor = FetchDescriptor<ServiceTypeTemplate>(
            predicate: #Predicate<ServiceTypeTemplate> { $0.isEnabled },
            sortBy: [SortDescriptor(\.name)]
        )

        guard let vehicles = try? context.fetch(vehicleDescriptor),
              let templates = try? context.fetch(templateDescriptor),
              !vehicles.isEmpty else {
            return nil
        }

        var allDueServices: [(vehicle: Vehicle, template: ServiceTypeTemplate, due: DueServiceInfo)] = []

        for vehicle in vehicles {
            let dueServices = ReminderCalculator.calculateDueServices(
                for: vehicle,
                templates: templates,
                currentDate: Date()
            )

            for dueService in dueServices {
                allDueServices.append((vehicle, dueService.template, dueService))
            }
        }

        // Sort by priority: overdue first, then by days/km until due
        let sorted = allDueServices.sorted { first, second in
            if first.due.status == .overdue && second.due.status != .overdue {
                return true
            }
            if first.due.status != .overdue && second.due.status == .overdue {
                return false
            }

            let firstDays = first.due.daysUntilDue ?? Int.max
            let secondDays = second.due.daysUntilDue ?? Int.max
            return firstDays < secondDays
        }

        guard let first = sorted.first else {
            return nil
        }

        return NextServiceInfo(
            vehicleName: first.vehicle.name,
            serviceName: first.template.name,
            status: first.due.status,
            daysUntilDue: first.due.daysUntilDue,
            kmUntilDue: first.due.kmUntilDue,
            unitPreference: first.vehicle.unitPreference
        )
    }
}

struct ServiceEntry: TimelineEntry {
    let date: Date
    let nextService: NextServiceInfo?
}

struct NextServiceInfo {
    let vehicleName: String
    let serviceName: String
    let status: DueStatus
    let daysUntilDue: Int?
    let kmUntilDue: Double?
    let unitPreference: DistanceUnit
}

struct ServiceAgendaWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(service: entry.nextService)
        case .systemMedium:
            MediumWidgetView(service: entry.nextService)
        case .accessoryCircular:
            CircularWidgetView(service: entry.nextService)
        case .accessoryRectangular:
            RectangularWidgetView(service: entry.nextService)
        default:
            SmallWidgetView(service: entry.nextService)
        }
    }
}

struct SmallWidgetView: View {
    let service: NextServiceInfo?

    var body: some View {
        if let service = service {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .foregroundStyle(service.status.color)
                    Spacer()
                    Text(service.status.rawValue.uppercased())
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(service.status.textColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(service.status.color)
                        .cornerRadius(4)
                }

                Text(service.serviceName)
                    .font(.headline)
                    .lineLimit(2)

                Spacer()

                if let days = service.daysUntilDue {
                    Text(days > 0 ? "in \(days) days" : "overdue")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let km = service.kmUntilDue {
                    let displayDistance = DistanceFormatter.toDisplayValue(km, unit: service.unitPreference)
                    let unitText = service.unitPreference == .kilometers ? "km" : "mi"
                    Text(km > 0 ? "in \(Int(displayDistance)) \(unitText)" : "overdue")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
        } else {
            VStack(spacing: 8) {
                Image(systemName: "car.fill")
                    .font(.title)
                    .foregroundStyle(.secondary)
                Text("No services due")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
    }
}

struct MediumWidgetView: View {
    let service: NextServiceInfo?

    var body: some View {
        if let service = service {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "wrench.and.screwdriver.fill")
                            .foregroundStyle(service.status.color)
                        Text(service.status.rawValue.uppercased())
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(service.status.textColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(service.status.color)
                            .cornerRadius(4)
                    }

                    Text(service.serviceName)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text(service.vehicleName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    if let days = service.daysUntilDue {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(abs(days))")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("days")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if let km = service.kmUntilDue {
                        let displayDistance = DistanceFormatter.toDisplayValue(km, unit: service.unitPreference)
                        let unitText = service.unitPreference == .kilometers ? "km" : "mi"
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(Int(abs(displayDistance)))")
                                .font(.title3)
                                .fontWeight(.semibold)
                            Text(unitText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding()
        } else {
            HStack(spacing: 12) {
                Image(systemName: "car.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text("All Clear!")
                        .font(.headline)
                    Text("No services due")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding()
        }
    }
}

struct CircularWidgetView: View {
    let service: NextServiceInfo?

    var body: some View {
        if let service = service, let days = service.daysUntilDue {
            ZStack {
                AccessoryWidgetBackground()

                VStack(spacing: 2) {
                    Text("\(abs(days))")
                        .font(.headline)
                        .fontWeight(.bold)
                    Text("days")
                        .font(.caption2)
                }
            }
        } else {
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "checkmark")
                    .font(.headline)
            }
        }
    }
}

struct RectangularWidgetView: View {
    let service: NextServiceInfo?

    var body: some View {
        if let service = service {
            HStack(spacing: 8) {
                Image(systemName: "wrench.and.screwdriver.fill")
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(service.serviceName)
                        .font(.headline)
                        .lineLimit(1)

                    if let days = service.daysUntilDue {
                        Text(days > 0 ? "in \(days) days" : "overdue")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()
            }
        } else {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.green)

                Text("All services up to date")
                    .font(.caption)
            }
        }
    }
}

#Preview(as: .systemSmall) {
    ServiceAgendaWidget()
} timeline: {
    ServiceEntry(date: .now, nextService: NextServiceInfo(
        vehicleName: "Honda Civic",
        serviceName: "Oil Change",
        status: .dueSoon,
        daysUntilDue: 15,
        kmUntilDue: 500,
        unitPreference: .kilometers
    ))
    ServiceEntry(date: .now, nextService: nil)
}

#Preview(as: .systemMedium) {
    ServiceAgendaWidget()
} timeline: {
    ServiceEntry(date: .now, nextService: NextServiceInfo(
        vehicleName: "Honda Civic",
        serviceName: "Oil Change",
        status: .overdue,
        daysUntilDue: -5,
        kmUntilDue: -200,
        unitPreference: .kilometers
    ))
}

#Preview(as: .accessoryCircular) {
    ServiceAgendaWidget()
} timeline: {
    ServiceEntry(date: .now, nextService: NextServiceInfo(
        vehicleName: "Honda Civic",
        serviceName: "Oil Change",
        status: .dueSoon,
        daysUntilDue: 15,
        kmUntilDue: 500,
        unitPreference: .kilometers
    ))
}

#Preview(as: .accessoryRectangular) {
    ServiceAgendaWidget()
} timeline: {
    ServiceEntry(date: .now, nextService: NextServiceInfo(
        vehicleName: "Honda Civic",
        serviceName: "Oil Change",
        status: .upcoming,
        daysUntilDue: 45,
        kmUntilDue: 2000,
        unitPreference: .kilometers
    ))
}
