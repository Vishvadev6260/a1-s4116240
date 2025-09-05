import SwiftUI

struct Chip: View {
    var label: String

    var body: some View {
        Text(label)
            .font(.footnote)
            .padding(8)
            .background(Color.blue.opacity(0.2), in: RoundedRectangle(cornerRadius: 16))
            .foregroundColor(.blue)
    }
}
