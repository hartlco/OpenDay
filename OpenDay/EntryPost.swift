import Foundation
import CoreData
import LocationService
import OpenKit

#if os(macOS)
import AppKit
#endif

public class EntryPost: NSManagedObject, Identifiable {
    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var entryDate: Date?
    @NSManaged public var images: Set<EntryImage>?
    @NSManaged public var location: EntryLocation?

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter
    }()

    @objc var sectionDate: String {
        return EntryPost.formatter.string(from: entryDate ?? Date())
    }
}

extension EntryImage: Identifiable { }

extension EntryImage {
    var openImage: OKImage {
        return OKImage(data: data!)!
    }
}

extension EntryLocation {
    func update(from location: Location) {
        self.city = location.city
        self.longitude = location.longitude
        self.latitude = location.latitude
        self.isoCountryCode = location.isoCountryCode
        self.street = location.street
    }

    var locationServiceLocation: Location {
        return Location(latitude: latitude,
                        longitude: longitude,
                        isoCountryCode: isoCountryCode,
                        street: street,
                        city: city)
    }
}
