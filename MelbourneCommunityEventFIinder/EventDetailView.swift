//
//  EventDetailView.swift
//  MelbourneCommunityEventFIinder
//
//  Created by Vishvadev Singh Shaktawat on 4/9/2025.
//
import SwiftUI

struct EventDetailView: View {
    let event: Event
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 16) {
            // Image
            AsyncImage(url: URL(string: event.imageURL)) { img in
                img.resizable().scaledToFill()
            } placeholder: {
                ZStack { Rectangle().fill(Color.secondary.opacity(0.15)); ProgressView() }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            // Text
            VStack(alignment: .leading, spacing: 8) {
                Text(event.name)
                    .font(.title2).bold()
                    .lineLimit(2)

                Text(event.dateTime)
                    .font(.headline)

                Text("\(event.venue) • \(event.city)")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Button {
                // Ticketmaster pages usually include the event id in their deep link form:
                if let url = URL(string: "https://www.ticketmaster.com/event/\(event.id)") {
                    openURL(url)
                }
            } label: {
                Label("Open in Ticketmaster", systemImage: "safari")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .presentationDetents([.medium, .large])
    }
}

