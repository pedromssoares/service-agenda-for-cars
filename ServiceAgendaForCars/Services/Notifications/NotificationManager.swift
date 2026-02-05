import Foundation
import UserNotifications
import SwiftData

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var permissionGranted = false

    private let notificationCenter = UNUserNotificationCenter.current()
    private let maxNotifications = 40

    private init() {}

    // MARK: - Permission

    func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            permissionGranted = granted
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }

    func checkPermissionStatus() async {
        let settings = await notificationCenter.notificationSettings()
        permissionGranted = settings.authorizationStatus == .authorized
    }

    // MARK: - Scheduling

    func scheduleNotifications(for dueServices: [DueService]) async {
        // Check permission first
        await checkPermissionStatus()
        guard permissionGranted else { return }

        // Remove all existing notifications
        notificationCenter.removeAllPendingNotificationRequests()

        // Sort by urgency and take top 40
        let servicesToSchedule = dueServices
            .filter { shouldScheduleNotification(for: $0) }
            .prefix(maxNotifications)

        for dueService in servicesToSchedule {
            await scheduleNotification(for: dueService)
        }

        print("Scheduled \(servicesToSchedule.count) notifications")
    }

    private func shouldScheduleNotification(for dueService: DueService) -> Bool {
        // Don't schedule for services that are far in the future
        // Only schedule if:
        // - Overdue
        // - Due soon
        // - Upcoming but within 60 days or 2000 km

        if dueService.status == .overdue || dueService.status == .dueSoon {
            return true
        }

        // For upcoming, only schedule if reasonably close
        if let days = dueService.daysUntilDue, days <= 60 {
            return true
        }

        if let distanceKm = dueService.distanceUntilDueKm, distanceKm <= 2000 {
            return true
        }

        return false
    }

    private func scheduleNotification(for dueService: DueService) async {
        let content = UNMutableNotificationContent()
        content.title = "Service Due: \(dueService.serviceType.name)"
        content.body = createNotificationBody(for: dueService)
        content.sound = .default
        content.categoryIdentifier = "SERVICE_REMINDER"

        // Determine when to fire the notification
        let trigger = createTrigger(for: dueService)

        let identifier = "service-\(dueService.vehicle.id.uuidString)-\(dueService.serviceType.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await notificationCenter.add(request)
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }

    private func createNotificationBody(for dueService: DueService) -> String {
        var parts: [String] = []

        parts.append(dueService.vehicle.name)

        if dueService.isOverdueByDate {
            if let dueDate = dueService.dueDateByDate {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                parts.append("Overdue since \(formatter.string(from: dueDate))")
            }
        } else if dueService.isOverdueByDistance {
            if let dueOdometer = dueService.dueOdometerKm {
                let formatted = DistanceFormatter.formatDistance(dueOdometer, unit: dueService.vehicle.unitPreference)
                parts.append("Overdue at \(formatted)")
            }
        } else {
            // Not yet overdue
            if let days = dueService.daysUntilDue, days > 0 {
                parts.append("Due in \(days) days")
            }

            if let distanceKm = dueService.distanceUntilDueKm, distanceKm > 0 {
                let formatted = DistanceFormatter.formatDistance(distanceKm, unit: dueService.vehicle.unitPreference)
                parts.append("or in \(formatted)")
            }
        }

        return parts.joined(separator: " • ")
    }

    private func createTrigger(for dueService: DueService) -> UNNotificationTrigger? {
        // For overdue services, fire immediately (well, in 5 seconds for testing)
        if dueService.status == .overdue {
            return UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        }

        // For due soon or upcoming, fire on the due date (or close to it)
        if let dueDate = dueService.dueDateByDate {
            // Fire at 9 AM on the due date
            let calendar = Calendar.current

            // If due date is in the past, fire immediately
            if dueDate < Date() {
                return UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            }

            // Otherwise fire at 9 AM on due date
            var components = calendar.dateComponents([.year, .month, .day], from: dueDate)
            components.hour = 9
            components.minute = 0

            return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        }

        // For distance-only reminders, fire immediately if close
        if let distanceKm = dueService.distanceUntilDueKm, distanceKm <= 500 {
            return UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        }

        // Default: fire in 1 day
        return UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false)
    }

    // MARK: - Debugging

    func getPendingNotificationCount() async -> Int {
        let requests = await notificationCenter.pendingNotificationRequests()
        return requests.count
    }
}
