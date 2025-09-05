import SwiftUI

struct EventListView: View {
    @StateObject private var network = NetworkManager()  // Your NetworkManager to fetch events
    
    // Query controls
    @State private var city: String = "Melbourne"
    @State private var size: Int = 20
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationStack {
            List(filteredEvents) { event in
                NavigationLink(destination: EventDetailsScreen(event: event)) {
                    EventRow(event: event) // Display event row
                }
            }
            .overlay {
                if network.events.isEmpty && network.lastError == nil {
                    ProgressView().controlSize(.large) // Show loading
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
            .navigationTitle("Upcoming Events")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        fetch()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .help("Refresh")
                }
            }
            .searchable(text: $searchText, placement: .toolbar, prompt: "Filter by name or venue")
            .safeAreaInset(edge: .top) {
                // Query controls bar
                HStack(spacing: 12) {
                    TextField("City", text: $city)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 220)
                    
                    Stepper("Size: \(size)", value: $size, in: 5...50, step: 5)
                    
                    Button("Find") { fetch() }
                        .buttonStyle(.borderedProminent)
                }
                .padding(.horizontal)
                .padding(.vertical, 6)
                .background(.thinMaterial)
            }
        }
        .onAppear { fetch() }
    }
    
    // Local filter for the search field
    private var filteredEvents: [Event] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return network.events
        }
        let q = searchText.lowercased()
        return network.events.filter {
            $0.name.lowercased().contains(q) ||
            $0.venue.lowercased().contains(q)
        }
    }

    private func fetch() {
        network.fetchEvents(city: city, size: size)
    }
}
