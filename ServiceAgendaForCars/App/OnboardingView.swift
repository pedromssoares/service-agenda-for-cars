import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var notificationManager: NotificationManager

    @State private var vehicleName: String = ""
    @State private var unitPreference: DistanceUnit = .kilometers
    @State private var currentOdometer: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "car.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(ColorTheme.info)

                VStack(spacing: 8) {
                    Text("Welcome to Service Agenda")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Track your car's maintenance and never miss a service")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer()

                VStack(spacing: 16) {
                    Text("Let's add your first vehicle")
                        .font(.headline)

                    VStack(spacing: 12) {
                        TextField("Vehicle Name (e.g., Honda Civic)", text: $vehicleName)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()

                        Picker("Distance Unit", selection: $unitPreference) {
                            Text("Kilometers").tag(DistanceUnit.kilometers)
                            Text("Miles").tag(DistanceUnit.miles)
                        }
                        .pickerStyle(.segmented)

                        HStack {
                            TextField("Current Odometer", text: $currentOdometer)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)

                            Text(unitPreference == .kilometers ? "km" : "mi")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal)

                    Button {
                        addVehicleAndContinue()
                    } label: {
                        Text("Get Started")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(vehicleName.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : ColorTheme.info)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                    .disabled(vehicleName.trimmingCharacters(in: .whitespaces).isEmpty)
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
        }
    }

    private func addVehicleAndContinue() {
        let odometerValue = Double(currentOdometer) ?? 0
        let odometerKm = DistanceFormatter.toStoredValue(odometerValue, unit: unitPreference)

        let vehicle = Vehicle(
            name: vehicleName.trimmingCharacters(in: .whitespaces),
            unitPreference: unitPreference,
            currentOdometerKm: odometerKm
        )
        modelContext.insert(vehicle)
        try? modelContext.save()

        // Request notification permission
        Task {
            _ = await notificationManager.requestPermission()
            dismiss()
        }
    }
}

#Preview {
    OnboardingView()
}
