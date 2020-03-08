import UIKit
import CoreData
import LocationService

public class EntryPost: NSManagedObject, Identifiable {
    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var entryDate: Date?
    @NSManaged public var images: Set<EntryImage>?
    @NSManaged public var location: EntryLocation?
}

extension EntryImage: Identifiable { }

extension EntryImage {
    var uiimage: UIImage {
        return UIImage(data: data!)!
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
