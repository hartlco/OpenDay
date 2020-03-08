import Foundation
import CoreLocation
import Contacts
import Combine

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
                self.locationManager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse:
                self.locationManager.startUpdatingLocation()
            default:
                return
            }

        }
    }

    public func getLocation(from location: CLLocation) -> Future<Location, Error> {
        return Future<Location, Error> { promise in
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location,
                                            completionHandler: { placemarks, error in
                                                if error == nil {
                                                    let placemark = placemarks?[0]

                                                    let location = Location(latitude: location.coordinate.latitude,
                                                                            longitude: location.coordinate.longitude,
                                                                            isoCountryCode: placemark?.isoCountryCode,
                                                                            street: placemark?.postalAddress?.street,
                                                                            city: placemark?.postalAddress?.city)

                                                    promise(Result.success(location))
                                                } else {
                                                    let location = Location(latitude: location.coordinate.latitude,
                                                                            longitude: location.coordinate.longitude)

                                                    promise(Result.success(location))
                                                }
            })

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

        let geocoder = CLGeocoder()

        geocoder.reverseGeocodeLocation(firstLocation,
                                        completionHandler: { [weak self] placemarks, error in
                                            guard let self = self else { return }
                                            if error == nil {
                                                let placemark = placemarks?[0]

                                                let location = Location(latitude: firstLocation.coordinate.latitude,
                                                                        longitude: firstLocation.coordinate.longitude,
                                                                        isoCountryCode: placemark?.isoCountryCode,
                                                                        street: placemark?.postalAddress?.street,
                                                                        city: placemark?.postalAddress?.city)

                                                self.runningPromise?(Result.success(location))
                                            } else {
                                                let location = Location(latitude: firstLocation.coordinate.latitude,
                                                                        longitude: firstLocation.coordinate.longitude)

                                                self.runningPromise?(Result.success(location))
                                            }
        })
    }
}

public struct Location {
    public let latitude: Double
    public let longitude: Double
    public let isoCountryCode: String?
    public let street: String?
    public let city: String?

    public init(latitude: Double,
                longitude: Double,
                isoCountryCode: String? = nil,
                street: String? = nil,
                city: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.isoCountryCode = isoCountryCode
        self.street = street
        self.city = city
    }
}
