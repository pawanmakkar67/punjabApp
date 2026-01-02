
import Foundation
import CoreLocation
import MapKit
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var locationName: String?
    @Published var isLoading = false
    @Published var permissionDenied = false
    @Published var searchResults: [String] = []
    
    // Throttle search
    private var searchSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        searchSubject
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .sink { [weak self] query in
                self?.performSearch(query: query)
            }
            .store(in: &cancellables)
    }
    
    func search(query: String) {
        searchSubject.send(query)
    }
    
    private func performSearch(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        // Optional: prioritize near current location
        if let location = locationManager.location {
            request.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        }
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Search error: \(error.localizedDescription)")
                return
            }
            
            if let response = response {
                // Map items to formatted strings
                self.searchResults = response.mapItems.compactMap { item in
                    var name = item.name ?? ""
                    if let locality = item.placemark.locality {
                        name += ", \(locality)"
                    }
                    if let adminArea = item.placemark.administrativeArea {
                        name += ", \(adminArea)"
                    }
                    return name
                }
            }
        }
    }
    
    func requestLocation() {
        isLoading = true
        permissionDenied = false
        
        let status = locationManager.authorizationStatus
        
        if status == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        } else {
            // Denied or restricted
            isLoading = false
            permissionDenied = true
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            if isLoading {
                 manager.requestLocation()
            }
        } else if status == .denied || status == .restricted {
            if isLoading {
                isLoading = false
                permissionDenied = true
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            isLoading = false
            return
        }
        
        // Reverse Geocode
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    return
                }
                
                if let placemark = placemarks?.first {
                    var locationComponents: [String] = []
                    
                    // Specific place name (e.g. "Apple Park")
                    if let name = placemark.name {
                        locationComponents.append(name)
                    }
                    
                    // Street (e.g. "Infinite Loop")
                    if let thoroughfare = placemark.thoroughfare {
                        if !locationComponents.contains(thoroughfare) {
                            locationComponents.append(thoroughfare)
                        }
                    }
                    
                    // Sub-locality (e.g. "Cupertino")
                    if let subLocality = placemark.subLocality {
                         if !locationComponents.contains(subLocality) {
                            locationComponents.append(subLocality)
                        }
                    } else if let locality = placemark.locality {
                         // Fallback to City if sub-locality missing
                         if !locationComponents.contains(locality) {
                            locationComponents.append(locality)
                        }
                    }
                    
                    // Administrative Area (State)
//                    if let administrativeArea = placemark.administrativeArea {
//                        locationComponents.append(administrativeArea)
//                    }
                    
                    self?.locationName = locationComponents.joined(separator: ", ")
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager Error: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
}
