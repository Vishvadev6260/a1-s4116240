import SwiftUI

struct ContentView: View {
    @StateObject private var network = NetworkManager()
    
    @State private var searchText: String = "Melbourne"
    @State private var eventSize: Int = 20

    var body: some View {
        NavigationView {
            List(network.events) { event in
                NavigationLink(destination: EventMapScreen(events: network.events)) {
                    EventRow(event: event)  // Pass the event object to EventRow
                }
            }
            .overlay {
                if network.events.isEmpty && network.lastError == nil {
                    ProgressView()
                        .controlSize(.large)
                }
            }
            .overlay(alignment: .bottom) {
                if let err = network.lastError {
                    Text(err)
                        .font(.callout)
                        .foregroundStyle(.red)
                        .padding(8)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
                        .padding()
                }
            }

            .navigationTitle("Local Events")
            .onAppear {
                network.fetchEvents(city: "Melbourne")
            }
        }
    }
}


