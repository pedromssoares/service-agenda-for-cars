import SwiftUI

struct ColorTheme {
    // Status colors - work in both light and dark mode
    static let overdue = Color.red
    static let dueSoon = Color.orange
    static let upcoming = Color.blue

    // Chart colors
    static let chartPrimary = Color.blue
    static let chartSecondary = Color.green
    static let chartTertiary = Color.orange

    // Backgrounds
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let listBackground = Color(UIColor.systemGroupedBackground)

    // Text colors (semantic - automatically adapt)
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let tertiaryText = Color(UIColor.tertiaryLabel)

    // Accent colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue

    // Photo viewer
    static let photoViewerBackground = Color.black
    static let photoViewerToolbar = Color.black.opacity(0.8)

    // Empty states
    static let emptyStateIcon = Color.gray.opacity(0.5)
}

// Extension for status badge colors
extension DueService.DueStatus {
    var color: Color {
        switch self {
        case .overdue: return ColorTheme.overdue
        case .dueSoon: return ColorTheme.dueSoon
        case .upcoming: return ColorTheme.upcoming
        }
    }

    var textColor: Color {
        // White text works on all badge colors in both modes
        return .white
    }
}
