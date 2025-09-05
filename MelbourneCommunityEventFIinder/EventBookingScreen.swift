import SwiftUI

struct EventBookingScreen: View {
    let event: Event

    var body: some View {
        VStack {
            Text("Book Tickets for \(event.name)")
                .font(.largeTitle)
                .padding()

            Button(action: {
                // Handle booking action
                print("Booking for event \(event.name)")
            }) {
                Text("RSVP Now")
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Book Tickets")
    }
}
