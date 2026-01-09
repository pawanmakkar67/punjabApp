//
//  PostMapView.swift
//  PunjabAppNew
//
//  Created by AutoAgent on 3/1/2026.
//

import SwiftUI
import MapKit
import CoreLocation

struct PostMapView: View {
    let locationName: String
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default SF
        span: MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)
    )
    @State private var coordinate: CLLocationCoordinate2D?
    @State private var isLoading = true
    @State private var loadError = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if let coordinate = coordinate {
                    Map(coordinateRegion: $region, annotationItems: [MapLocation(coordinate: coordinate)]) { location in
                        MapMarker(coordinate: location.coordinate, tint: .red)

                    }
                    .disabled(true) // Disable interaction for a "preview" feel
                } else if isLoading {
                    ZStack {
                        Color.gray.opacity(0.1)
                        ProgressView()
                    }
                } else {
                    ZStack {
                        Color.gray.opacity(0.1)
                        if loadError {
                            Text("Map unavailable")
                                .font(.caption)
                                .foregroundColor(.gray)
                        } else {
                             Image(systemName: "map")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Location Footer
            HStack {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.red)
                    .font(.title2)
                Text(locationName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                    .lineLimit(1)
                Spacer()
            }
            .padding(.top, 8)
            .padding(.horizontal, 4)
        }
        .onAppear {
            geocodeLocation()
        }
    }
    
    private func geocodeLocation() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(locationName) { placemarks, error in
            isLoading = false
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                loadError = true
                return
            }
            
            if let location = placemarks?.first?.location {
                self.coordinate = location.coordinate
                self.region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                )
            } else {
                loadError = true
            }
        }
    }
}

struct MapLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

#Preview {
    PostMapView(locationName: "Eiffel Tower, Paris")
        .padding()
}
