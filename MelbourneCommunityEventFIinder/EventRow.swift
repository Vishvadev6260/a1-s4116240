import SwiftUI

struct EventRow: View {
    let event: Event  // Make sure the type matches what is used in `network.events`

    var body: some View {
        HStack {
            Text(event.name)  // Adjust with event properties as necessary
                .font(.headline)
            Spacer()
            Text(event.dateTime)  // Adjust to match how `event.dateTime` is formatted
                .font(.subheadline)
        }
        .padding()
    }
}

