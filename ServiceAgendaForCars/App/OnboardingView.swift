import SwiftUI
import SwiftData

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var notificationManager: NotificationManager

    @Query(sort: \ServiceTypeTemplate.name) private var allServiceTemplates: [ServiceTypeTemplate]

    @State private var currentStep = 0
    @State private var vehicleName: String = ""
    @State private var unitPreference: DistanceUnit = .kilometers
    @State private var currentOdometer: String = ""
    @State private var isNewVehicle: Bool = false
    @State private var createdVehicle: Vehicle?

    var enabledTemplates: [ServiceTypeTemplate] {
        allServiceTemplates.filter { $0.isEnabled }
    }

    var body: some View {
        NavigationStack {
            Group {
                if currentStep == 0 {
                    WelcomeStepView(
                        vehicleName: $vehicleName,
                        unitPreference: $unitPreference,
                        currentOdometer: $currentOdometer,
                        isNewVehicle: $isNewVehicle,
                        onContinue: createVehicleAndProceed
                    )
                } else if currentStep > 0 && currentStep <= enabledTemplates.count {
                    ServiceHistoryStepView(
                        vehicle: createdVehicle!,
                        template: enabledTemplates[currentStep - 1],
                        stepNumber: currentStep,
                        totalSteps: enabledTemplates.count,
                        onSkip: nextStep,
                        onSave: { event in
                            saveServiceEvent(event)
                            nextStep()
                        }
                    )
                }
            }
        }
    }

    private func createVehicleAndProceed() {
        let odometerValue = Double(currentOdometer) ?? 0
        let odometerKm = DistanceFormatter.toStoredValue(odometerValue, unit: unitPreference)

        let vehicle = Vehicle(
            name: vehicleName.trimmingCharacters(in: .whitespaces),
            unitPreference: unitPreference,
            currentOdometerKm: odometerKm
        )
        modelContext.insert(vehicle)
        try? modelContext.save()

        createdVehicle = vehicle

        // Skip service history if brand new vehicle
        if isNewVehicle {
            finishOnboarding()
        } else {
            currentStep = 1
        }
    }

    private func saveServiceEvent(_ event: ServiceEvent) {
        modelContext.insert(event)
        try? modelContext.save()
    }

    private func nextStep() {
        if currentStep >= enabledTemplates.count {
            finishOnboarding()
        } else {
            currentStep += 1
        }
    }

    private func finishOnboarding() {
        Task {
            _ = await notificationManager.requestPermission()
            dismiss()
        }
    }
}

struct WelcomeStepView: View {
    @Binding var vehicleName: String
    @Binding var unitPreference: DistanceUnit
    @Binding var currentOdometer: String
    @Binding var isNewVehicle: Bool
    let onContinue: () -> Void

    var isValid: Bool {
        !vehicleName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !currentOdometer.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
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

                    Toggle("This is a brand new vehicle", isOn: $isNewVehicle)
                        .tint(ColorTheme.info)
                }
                .padding(.horizontal)

                VStack(spacing: 8) {
                    Button {
                        onContinue()
                    } label: {
                        Text(isNewVehicle ? "Get Started" : "Continue to Service History")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValid ? ColorTheme.info : Color.gray)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                    .disabled(!isValid)

                    if !isNewVehicle {
                        Text("We'll ask about your service history next")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
    }
}

struct ServiceHistoryStepView: View {
    @Environment(\.modelContext) private var modelContext
    let vehicle: Vehicle
    let template: ServiceTypeTemplate
    let stepNumber: Int
    let totalSteps: Int
    let onSkip: () -> Void
    let onSave: (ServiceEvent) -> Void

    @State private var hasServiceHistory = false
    @State private var serviceDate = Date()
    @State private var odometer: String = ""
    @State private var cost: String = ""
    @State private var notes: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)

                    Rectangle()
                        .fill(ColorTheme.info)
                        .frame(width: geometry.size.width * CGFloat(stepNumber) / CGFloat(totalSteps), height: 4)
                }
            }
            .frame(height: 4)

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Step \(stepNumber) of \(totalSteps)")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Image(systemName: "wrench.and.screwdriver.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(ColorTheme.info)

                        Text(template.name)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text("Have you done this service before?")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 32)

                    // Toggle
                    Toggle("Yes, I have service history", isOn: $hasServiceHistory)
                        .padding(.horizontal)

                    // Service details form
                    if hasServiceHistory {
                        VStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("When was it done?")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                DatePicker("Service Date", selection: $serviceDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("At what odometer?")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                HStack {
                                    TextField("Odometer", text: $odometer)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(.roundedBorder)

                                    Text(vehicle.unitPreference == .kilometers ? "km" : "mi")
                                        .foregroundStyle(.secondary)
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Cost (optional)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                TextField("Cost", text: $cost)
                                    .keyboardType(.decimalPad)
                                    .textFieldStyle(.roundedBorder)
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes (optional)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                TextField("Notes", text: $notes)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Spacer()
                }
            }

            // Bottom buttons
            VStack(spacing: 12) {
                if hasServiceHistory {
                    Button {
                        saveService()
                    } label: {
                        Text("Save & Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ColorTheme.info)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                    .disabled(odometer.trimmingCharacters(in: .whitespaces).isEmpty)
                }

                Button {
                    onSkip()
                } label: {
                    Text(hasServiceHistory ? "Skip This Service" : "Skip")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(uiColor: .systemBackground))
        }
        .animation(.easeInOut, value: hasServiceHistory)
        .onAppear {
            // Pre-fill odometer with current vehicle odometer
            let displayOdometer = DistanceFormatter.toDisplayValue(vehicle.currentOdometerKm, unit: vehicle.unitPreference)
            odometer = String(Int(displayOdometer))
        }
    }

    private func saveService() {
        let odometerValue = Double(odometer) ?? 0
        let odometerKm = DistanceFormatter.toStoredValue(odometerValue, unit: vehicle.unitPreference)
        let costValue = Double(cost)

        let event = ServiceEvent(
            date: serviceDate,
            odometerKm: odometerKm,
            cost: costValue,
            notes: notes.trimmingCharacters(in: .whitespaces).isEmpty ? nil : notes
        )
        event.vehicle = vehicle
        event.serviceType = template

        onSave(event)
    }
}

#Preview {
    OnboardingView()
}
