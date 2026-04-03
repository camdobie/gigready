import SwiftUI

struct VenueListView: View {
    @StateObject private var firebaseService = FirebaseService.shared
    @State private var venues: [Venue] = []
    @State private var isLoading = false
    @State private var showAddVenue = false
    @State private var newVenueName = ""
    @State private var selectedVenue: Venue?

    var userId: String

    var body: some View {
        NavigationStack {
            VStack {
                if venues.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "building.2")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)

                        Text("No Venues Yet")
                            .font(.headline)

                        Text("Create a venue to get started")
                            .foregroundColor(.secondary)

                        Button(action: { showAddVenue = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Add Venue")
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
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                            ForEach(venues) { venue in
                                NavigationLink(destination: PerformanceListView(venue: venue, userId: userId)) {
                                    VenueCard(venue: venue)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Venues")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showAddVenue = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddVenue) {
                AddVenueSheet(isPresented: $showAddVenue) { name in
                    addVenue(name: name)
                }
            }
        }
        .onAppear {
            loadVenues()
        }
    }

    private func loadVenues() {
        isLoading = true
        firebaseService.loadVenues(for: userId) { venues in
            DispatchQueue.main.async {
                self.venues = venues.sorted { $0.name < $1.name }
                isLoading = false
            }
        }
    }

    private func addVenue(name: String) {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let newVenue = Venue(name: name)
        venues.append(newVenue)
        venues.sort { $0.name < $1.name }

        firebaseService.saveVenue(newVenue, for: userId)
    }
}

struct VenueCard: View {
    let venue: Venue

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(venue.name)
                    .font(.headline)
                    .lineLimit(1)

                Spacer()

                Image(systemName: "building.2.fill")
                    .foregroundColor(.blue)
            }

            if let location = venue.location {
                Text(location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            HStack {
                Image(systemName: "music.note")
                    .font(.caption)
                Text("\(venue.performances.count) performances")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct AddVenueSheet: View {
    @Binding var isPresented: Bool
    @State private var venueName = ""
    let onAdd: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Venue Name", text: $venueName)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                Spacer()
            }
            .navigationTitle("Add Venue")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Add") {
                        onAdd(venueName)
                        isPresented = false
                    }
                    .disabled(venueName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    VenueListView(userId: "test-user")
}
