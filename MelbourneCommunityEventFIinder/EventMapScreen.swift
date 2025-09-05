import SwiftUI

struct EventMapScreen: View {
    let events: [Event]  // Ensure it takes an array of events

    var body: some View {
        // Your map or event-related views go here
        Text("Displaying map for \(events.count) events")
    }
}

