import SwiftUI

struct SearchBarView: View {
    @Binding var text: String

    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search…", text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)

                if !text.isEmpty {
                    Button(action: { text = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(8)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
