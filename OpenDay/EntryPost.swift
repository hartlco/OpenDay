import UIKit
import CoreData

public class EntryPost: NSManagedObject, Identifiable {
    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var entryDate: Date?
    @NSManaged public var images: Set<EntryImage>?
}

extension EntryImage: Identifiable { }

extension EntryImage {
    var uiimage: UIImage {
        return UIImage(data: data!)!
    }
}
