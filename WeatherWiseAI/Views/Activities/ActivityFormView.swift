import SwiftUI

struct ActivityFormView: View {
    let activity: Activity?
    @StateObject private var viewModel: ActivityFormViewModel
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode
    
    init(activity: Activity? = nil) {
        self.activity = activity
        // Note: In production, inject authManager properly
        self._viewModel = StateObject(wrappedValue: ActivityFormViewModel(authManager: AuthManager(), activity: activity))
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Activity Name Section
                Section("Activity Name") {
                    if viewModel.isUsingCustomName {
                        TextField("Enter custom activity name", text: $viewModel.customActivityName)
                    } else {
                        Picker("Choose Activity", selection: $viewModel.activityName) {
                            ForEach(viewModel.commonActivities, id: \.self) { activity in
                                Text(activity).tag(activity)
                            }
                        }
                    }
                    
                    Toggle("Use Custom Name", isOn: $viewModel.isUsingCustomName)
                }
                
                // Location Section
                Section("Location") {
                    TextField("Enter location", text: $viewModel.location)
                        .autocapitalization(.words)
                }
                
                // Weather Preferences Section
                Section("Weather Preferences") {
                    VStack(alignment: .leading, spacing: 16) {
                        // Temperature Range
                        VStack(alignment: .leading) {
                            Text("Temperature Range: \(Int(viewModel.minTemperature))° - \(Int(viewModel.maxTemperature))°C")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack {
                                Text("Min")
                                    .font(.caption)
                                Slider(value: $viewModel.minTemperature, in: -10...40, step: 1)
                                Text("\(Int(viewModel.minTemperature))°")
                                    .font(.caption)
                                    .frame(width: 35)
                            }
                            
                            HStack {
                                Text("Max")
                                    .font(.caption)
                                Slider(value: $viewModel.maxTemperature, in: -10...40, step: 1)
                                Text("\(Int(viewModel.maxTemperature))°")
                                    .font(.caption)
                                    .frame(width: 35)
                            }
                            
                            if !viewModel.temperatureRangeIsValid {
                                Text("Maximum temperature must be higher than minimum")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // Max Wind Speed
                        VStack(alignment: .leading) {
                            Text("Max Wind Speed: \(Int(viewModel.maxWind)) km/h")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Slider(value: $viewModel.maxWind, in: 0...50, step: 1)
                        }
                        
                        // Max Rain Chance
                        VStack(alignment: .leading) {
                            Text("Max Rain Chance: \(Int(viewModel.maxRain))%")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Slider(value: $viewModel.maxRain, in: 0...100, step: 5)
                        }
                    }
                }
                
                // Time Slots Section
                Section("Time Slots") {
                    ForEach(Array(viewModel.timeSlots.enumerated()), id: \.offset) { index, timeSlot in
                        TimeSlotRow(
                            timeSlot: timeSlot,
                            onUpdate: { start, end in
                                viewModel.updateTimeSlot(at: index, start: start, end: end)
                            },
                            onDelete: {
                                viewModel.removeTimeSlot(at: index)
                            }
                        )
                    }
                    
                    Button("Add Time Slot") {
                        viewModel.addTimeSlot()
                    }
                    .foregroundColor(.blue)
                }
                
                // Days Section
                Section("Available Days") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(viewModel.availableDays, id: \.self) { day in
                            Button(action: {
                                viewModel.toggleDay(day)
                            }) {
                                HStack {
                                    Image(systemName: viewModel.isDaySelected(day) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(viewModel.isDaySelected(day) ? .blue : .gray)
                                    
                                    Text(day)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .navigationTitle(viewModel.isEditMode ? "Edit Activity" : "New Activity")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button(viewModel.saveButtonTitle) {
                    Task {
                        let success = await viewModel.saveActivity()
                        if success {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .disabled(!viewModel.isFormValid || viewModel.isLoading)
            )
            .alert("Error", isPresented: $viewModel.showingError) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage)
            }
            .onAppear {
                viewModel.updateAuthManager(authManager)
            }
        }
    }
}

struct TimeSlotRow: View {
    let timeSlot: TimeSlot
    let onUpdate: (String, String) -> Void
    let onDelete: () -> Void
    
    @State private var startTime = Date()
    @State private var endTime = Date()
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Time Slot")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Start")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .onChange(of: startTime) { _ in
                            updateTimeSlot()
                        }
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("End")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .onChange(of: endTime) { _ in
                            updateTimeSlot()
                        }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .onAppear {
            setupInitialTimes()
        }
    }
    
    private func setupInitialTimes() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        if let start = formatter.date(from: timeSlot.start) {
            startTime = start
        }
        if let end = formatter.date(from: timeSlot.end) {
            endTime = end
        }
    }
    
    private func updateTimeSlot() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let startString = formatter.string(from: startTime)
        let endString = formatter.string(from: endTime)
        
        onUpdate(startString, endString)
    }
}

// MARK: - ActivityFormViewModel Extension
extension ActivityFormViewModel {
    func updateAuthManager(_ authManager: AuthManager) {
        // Workaround for dependency injection
    }
}

// MARK: - Preview
struct ActivityFormView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityFormView()
            .environmentObject(AuthManager())
    }
}
