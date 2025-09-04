import SwiftUI

struct ContentView: View {
    @StateObject private var network = NetworkManager()
    @State private var city: String = "Melbourne"
    @State private var size: Int = 20
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            List(filteredEvents) { event in
                EventRow(event: event)
            }
            .overlay {
                if network.events.isEmpty && network.lastError == nil {
                    ProgressView().controlSize(.large)
                }
            }
            .navigationTitle("Local Events")
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
        }
        .searchable(text: $searchText, placement: .toolbar, prompt: "Filter by name or venue")
        .safeAreaInset(edge: .top) {
            HStack(spacing: 8) {
                TextField("City", text: $city)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 220)

                Stepper("Size: \(size)", value: $size, in: 5...50, step: 5)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Button("Find") { fetch() }
                    .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(.ultraThinMaterial)
        }
        .onAppear { fetch() }
        .alert("Error", isPresented: .constant(network.lastError != nil), actions: {
            Button("OK", role: .cancel) { network.lastError = nil }
        }, message: {
            Text(network.lastError ?? "")
        })
    }

    private var filteredEvents: [Event] {
        guard !searchText.isEmpty else { return network.events }
        let term = searchText.lowercased()
        return network.events.filter {
            $0.name.lowercased().contains(term) ||
            $0.venue.lowercased().contains(term)
        }
    }

    private func fetch() {
        network.fetchEvents(city: city, size: size)
    }
}

private struct EventRow: View {
    let event: Event

    var body: some View {
        HStack(spacing: 12) {
            EventImage(urlString: event.imageURL)
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.headline)
                    .lineLimit(2)

                Text(event.dateTime)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text("\(event.venue) · \(event.city)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .padding(.vertical, 6)
    }
}

private struct EventImage: View {
    let urlString: String

    var body: some View {
        if let url = URL(string: urlString), !urlString.isEmpty {
            // Works on macOS 12+
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty: ProgressView()
                case .success(let image): image.resizable().scaledToFill()
                case .failure: placeholder
                @unknown default: placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10).fill(Color.secondary.opacity(0.15))
            Image(systemName: "photo")
                .imageScale(.large)
                .foregroundStyle(.secondary)
        }
    }
}

