import Foundation
import CoreData
import LocationService
import OpenKit
import Models

#if os(macOS)
import AppKit
#endif

public class EntryPost: NSManagedObject, Identifiable {
    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var entryDate: Date?
    @NSManaged public var images: Set<EntryImage>?
    @NSManaged public var location: EntryLocation?
    @NSManaged public var weather: EntryWeather?

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()

    @objc var sectionDate: String {
        return EntryPost.formatter.string(from: entryDate ?? Date())
    }
}

extension EntryPost: Models.Post {
    public func getWeather() -> Weather? {
        return weather
    }

    public func getLocation() -> Location? {
        return location
    }

    public var orderedImages: [Image]? {
        return Array(images ?? [])
    }
}

public class EntryImage: NSManagedObject, Identifiable {
    @NSManaged public var data: Data?
    @NSManaged public var thumbnail: Data?
    @NSManaged public var imageDate: Date?
    @NSManaged public var post: EntryPost?
}

extension EntryImage: Models.Image {
    //swiftlint:disable identifier_name
    public var id: String {
        return objectID.uriRepresentation().absoluteString
    }
}

public class EntryLocation: NSManagedObject, Identifiable {
    @NSManaged public var city: String?
    @NSManaged public var isoCountryCode: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var street: String?
    @NSManaged public var post: EntryPost?
}

extension EntryLocation: Models.Location {
    public func getPost() -> Post? {
        return post
    }
}

extension EntryLocation {
    func update(from location: LocationServiceLocation) {
        self.city = location.city
        self.longitude = location.longitude
        self.latitude = location.latitude
        self.isoCountryCode = location.isoCountryCode
        self.street = location.street
    }

    var locationServiceLocation: LocationServiceLocation {
        return LocationServiceLocation(latitude: latitude,
                                       longitude: longitude,
                                       isoCountryCode: isoCountryCode,
                                       street: street,
                                       city: city)
    }
}

public class EntryWeather: NSManagedObject, Identifiable {
    @NSManaged public var temperature: Double
    @NSManaged public var weatherIconString: String?
    @NSManaged public var post: EntryPost?
}

extension EntryWeather: Models.Weather {
    public var weatherIcon: WeatherIcon? {
        guard let weatherIconString = weatherIconString else {
            return nil
        }

        return .matched(from: weatherIconString)
    }
}
