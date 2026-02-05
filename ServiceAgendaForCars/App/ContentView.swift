import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var vehicles: [Vehicle]
    @State private var showingOnboarding = false

    var body: some View {
        TabView {
            UpNextView()
                .tabItem {
                    Label("Up Next", systemImage: "clock")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .onAppear {
            // Show onboarding if no vehicles exist
            if vehicles.isEmpty {
                showingOnboarding = true
            }
        }
        .sheet(isPresented: $showingOnboarding) {
            OnboardingView()
                .interactiveDismissDisabled()
        }
    }
}

#Preview {
    ContentView()
}
