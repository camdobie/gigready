import SwiftUI

struct PerformanceListView: View {
    let venue: Venue
    let userId: String
    @State private var performances: [Performance] = []
    @State private var showAddPerformance = false
    @State private var selectedPerformance: Performance?

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
                            }
                        }
                        .onDelete(perform: deletePerformance)
                    }
                }
            }
            .navigationTitle(venue.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddPerformance = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddPerformance) {
                AddPerformanceSheet(isPresented: $showAddPerformance, venue: venue) { performance in
                    addPerformance(performance)
                }
            }
        }
        .onAppear {
            loadPerformances()
        }
    }

    private func loadPerformances() {
        // TODO: Load performances from Firebase
        // For now, create a default performance with a new setlist
    }

    private func addPerformance(_ performance: Performance) {
        performances.append(performance)
        performances.sort { ($0.performanceDate ?? Date()) > ($1.performanceDate ?? Date()) }
        // TODO: Save to Firebase
    }

    private func deletePerformance(at offsets: IndexSet) {
        for index in offsets {
            let performance = performances[index]
            // TODO: Delete from Firebase
        }
        performances.remove(atOffsets: offsets)
    }
}

struct AddPerformanceSheet: View {
    @Binding var isPresented: Bool
    let venue: Venue
    @State private var performanceName = ""
    @State private var performanceDate = Date()
    @State private var selectedSetlistIndex = 0
    let onCreate: (Performance) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Performance Details") {
                    TextField("Performance Name", text: $performanceName)
                    DatePicker("Date", selection: $performanceDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Add Performance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Create") {
                        let performance = Performance(
                            name: performanceName,
                            venueId: venue.id,
                            setlistId: UUID().uuidString,
                            performanceDate: performanceDate
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

#Preview {
    PerformanceListView(venue: Venue(name: "Test Venue"), userId: "test-user")
}
