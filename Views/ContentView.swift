import SwiftUI

struct ContentView: View {
    @StateObject private var firebaseService = FirebaseService.shared

    var body: some View {
        if firebaseService.isAuthenticated, let currentUser = firebaseService.currentUser {
            VenueListView(userId: currentUser.id)
        } else {
            AuthenticationView()
        }
    }
}

struct AuthenticationView: View {
    @StateObject private var firebaseService = FirebaseService.shared

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "music.note.list")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("GigReady")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Setlist & Lyrics Manager")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Button(action: {
                firebaseService.signInAnonymously()
            }) {
                HStack {
                    Image(systemName: "person.circle.fill")
                    Text("Get Started")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }

            if let errorMessage = firebaseService.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
