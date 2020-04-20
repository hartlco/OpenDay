import Foundation
import CoreLocation
import Contacts
import Combine
import Models

public final class LocationService: NSObject {
    var text = "Hello, World!"

    private let locationManager: CLLocationManager
    private var runningPromise: ((Result<Location, Error>) -> Void)?

    public init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        super.init()

        self.locationManager.delegate = self
    }

    public func getLocation() -> Future<Location, Error> {
        return Future<Location, Error> { [weak self] promise in
            guard let self = self else { return }

            guard CLLocationManager.locationServicesEnabled() else {
                return
            }

            self.runningPromise = promise

            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                #if os(iOS)
                self.locationManager.requestWhenInUseAuthorization()
                #endif

                #if os(macOS)
                self.locationManager.requestAlwaysAuthorization()
                #endif
            case .authorizedWhenInUse, .authorizedAlways:
                self.locationManager.startUpdatingLocation()
            case .restricted:
                return
            case .denied:
                return
            default:
                return
            }

        }
    }

    public func getLocation(from location: CLLocation) -> Future<Location, Error> {
        let coordinates = Location.Coordinates(longitude: location.coordinate.longitude,
                                               latitude: location.coordinate.latitude)

        return Future<Location, Error> { promise in
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location,
                                            completionHandler: { placemarks, error in
                                                guard error == nil,
                                                    let placemark = placemarks?.first else {
                                                        let location = Location(coordinates: coordinates,
                                                                                isoCountryCode: "", city: nil,
                                                                                name: nil)
                                                        promise(Result.success(location))
                                                        return
                                                }

                                                let location = Location(coordinates: coordinates,
                                                                        isoCountryCode: placemark.isoCountryCode ?? "",
                                                                        city: placemark.postalAddress?.city,
                                                                        name: placemark.postalAddress?.street)

                                                promise(Result.success(location))
            })

        }
    }

    public func getLocations(from addressString: String) -> Future<[Location], Error> {
        return Future<[Location], Error> { promise in
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(addressString) { placemarks, _ in
                guard let placemarks = placemarks else {
                    return
                }

                let locations: [Location] = placemarks.compactMap { placemark in
                    guard let location = placemark.location else {
                        return nil
                    }

                    let coordinate = Location.Coordinates(longitude: location.coordinate.longitude,
                                                          latitude: location.coordinate.latitude)

                    return Location(coordinates: coordinate,
                                    isoCountryCode: placemark.isoCountryCode ?? "",
                                    city: placemark.postalAddress?.city,
                                    name: placemark.postalAddress?.street)
                }

                promise(Result.success(locations))
            }
        }
    }
}

extension LocationService: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            return
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()

        guard let firstLocation = locations.first else {
            return
        }

        let coordinates = Location.Coordinates(longitude: firstLocation.coordinate.longitude,
                                               latitude: firstLocation.coordinate.latitude)

        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(firstLocation,
                                        completionHandler: { [weak self] placemarks, error in
                                            guard let self = self else { return }
                                            guard error == nil,
                                                let placemark = placemarks?.first else {
                                                    let location = Location(coordinates: coordinates,
                                                                            isoCountryCode: "", city: nil,
                                                                            name: nil)
                                                    self.runningPromise?(Result.success(location))
                                                    return
                                            }

                                            let location = Location(coordinates: coordinates,
                                                                    isoCountryCode: placemark.isoCountryCode ?? "",
                                                                    city: placemark.postalAddress?.city,
                                                                    name: placemark.postalAddress?.street)

                                            self.runningPromise?(Result.success(location))
        })
    }
}
