import SwiftUI

struct EventFilterScreen: View {
    @State private var selectedCategory: String = "Music"
    @State private var selectedDateRange: String = "Upcoming"

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Category")) {
                    Picker("Category", selection: $selectedCategory) {
                        Text("Music").tag("Music")
                        Text("Sports").tag("Sports")
                        Text("Theater").tag("Theater")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Date Range")) {
                    Picker("Date Range", selection: $selectedDateRange) {
                        Text("Upcoming").tag("Upcoming")
                        Text("All").tag("All")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Button(action: {
                    // Apply filters
                    print("Filters Applied")
                }) {
                    Text("Apply Filters")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Filters")
        }
    }
}
