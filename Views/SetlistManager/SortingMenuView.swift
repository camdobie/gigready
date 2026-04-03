import SwiftUI

struct SortingMenuView: View {
    @Binding var selectedOption: SortOption
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    Section("Sorting Options") {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: {
                                withAnimation {
                                    selectedOption = option
                                }
                                dismiss()
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(option.rawValue)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.primary)

                                        Text(option.description)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    if selectedOption == option {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("Sort Songs")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension SortOption {
    var description: String {
        switch self {
        case .original:
            return "Preserve original order"
        case .alphabetical:
            return "A to Z by song name"
        case .tempoSlowToFast:
            return "Ascending BPM"
        case .tempoMixed:
            return "Medium tempo in middle"
        case .randomized:
            return "Random order"
        }
    }
}

#Preview {
    @State var selectedOption = SortOption.original
    return SortingMenuView(selectedOption: $selectedOption)
}
