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

public class EntryWeather: NSManagedObject, Identifiable {
    @NSManaged public var temperature: Double
    @NSManaged public var weatherIconString: String?
    @NSManaged public var post: EntryPost?
}
