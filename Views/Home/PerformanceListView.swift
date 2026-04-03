import SwiftUI

struct PerformanceListView: View {
    let venue: Venue
    let userId: String
    @State private var performances: [Performance] = []
    @State private var showAddPerformance = false
    @State private var selectedPerformance: Performance?
    @StateObject private var firebaseService = FirebaseService.shared
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                if performances.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "calendar")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)

                        Text("No Performances")
                            .font(.headline)

                        Text("Create a performance to get started")
                            .foregroundColor(.secondary)

                        Button(action: { showAddPerformance = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Performance")
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .frame(maxWidth: .infinity)
                } else {
                    List {
                        ForEach(performances) { performance in
                            NavigationLink(destination: SetlistManagerView(setlistId: performance.setlistId, userId: userId)) {
                                PerformanceRow(performance: performance)
                            }
                        }
                        .onDelete(perform: deletePerformance)
                    }
                }
            }
            .navigationTitle(venue.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                    .foregroundColor(.blue)
                }

                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddPerformance = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddPerformance) {
                AddPerformanceSheet(
                    isPresented: $showAddPerformance,
                    venue: venue,
                    userId: userId
                ) { performance in
                    addPerformance(performance)
                }
            }
        }
        .onAppear {
            loadPerformances()
        }
    }

    private func loadPerformances() {
        // In a real implementation, load from Firebase
        // For now, we'll leave it empty
        performances = []
    }

    private func addPerformance(_ performance: Performance) {
        performances.append(performance)
        performances.sort { ($0.performanceDate ?? Date()) > ($1.performanceDate ?? Date()) }
        firebaseService.saveSetlist(Setlist(id: performance.setlistId, name: performance.name), for: userId)
    }

    private func deletePerformance(at offsets: IndexSet) {
        for index in offsets {
            let performance = performances[index]
            firebaseService.deleteSetlist(performance.setlistId, for: userId)
        }
        performances.remove(atOffsets: offsets)
    }
}

struct PerformanceRow: View {
    let performance: Performance

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(performance.name)
                        .font(.headline)

                    if let date = performance.performanceDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption)
                            Text(date, style: .date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }

            if let notes = performance.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

struct AddPerformanceSheet: View {
    @Binding var isPresented: Bool
    let venue: Venue
    let userId: String
    @State private var performanceName = ""
    @State private var performanceDate = Date()
    @State private var performanceNotes = ""
    @State private var duplicateFromExisting = false
    @State private var selectedSetlistIndex = 0
    let onCreate: (Performance) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Performance Details") {
                    TextField("Performance Name", text: $performanceName)
                        .placeholder(when: performanceName.isEmpty) {
                            Text("e.g., Concert at \(venue.name)")
                                .foregroundColor(.gray)
                        }

                    DatePicker("Date", selection: $performanceDate, displayedComponents: .date)
                }

                Section("Notes") {
                    TextEditor(text: $performanceNotes)
                        .frame(height: 60)
                }

                Section("Setlist Options") {
                    Toggle("Start with empty setlist", isOn: .constant(true))

                    Text("You'll be able to import songs or create them manually after creating the performance.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("New Performance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Create") {
                        let setlistName = "\(performanceName) - \(performanceDate.formatted(date: .abbreviated, time: .omitted))"
                        let performance = Performance(
                            name: performanceName,
                            venueId: venue.id,
                            setlistId: UUID().uuidString,
                            performanceDate: performanceDate,
                            notes: performanceNotes.isEmpty ? nil : performanceNotes
                        )
                        onCreate(performance)
                        isPresented = false
                    }
                    .disabled(performanceName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

extension View {
    func placeholder<Content: View>(when shouldShow: Bool, alignment: Alignment = .leading, @ViewBuilder placeholder: () -> Content) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    PerformanceListView(venue: Venue(name: "Test Venue"), userId: "test-user")
}
