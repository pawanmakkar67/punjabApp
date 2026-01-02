
import SwiftUI

struct LocationPickerView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedLocation: String
    @State private var searchText = ""
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        NavigationStack {
            List {
                Button(action: {
                    locationManager.requestLocation()
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                        if locationManager.isLoading {
                            Text("Fetching location...")
                                .foregroundColor(.gray)
                            ProgressView()
                                .padding(.leading, 5)
                        } else {
                            Text("Current Location")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .disabled(locationManager.isLoading)
                
                if locationManager.permissionDenied {
                    Text("Location permission denied. Please enable it in Settings.")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                ForEach(locationManager.searchResults, id: \.self) { location in
                    Button(action: {
                        selectedLocation = location
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.red)
                            Text(location)
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search for a location")
            .onChange(of: searchText) { query in
                locationManager.search(query: query)
            }
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onChange(of: locationManager.locationName) { newLocation in
                if let location = newLocation {
                    selectedLocation = location
                    dismiss()
                }
            }
        }
    }
}
