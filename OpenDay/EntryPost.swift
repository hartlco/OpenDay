import UIKit
import CoreData

public class EntryPost: NSManagedObject, Identifiable {
    @NSManaged public var title: String?
    @NSManaged public var body: String?
    @NSManaged public var entryDate: Date?
    @NSManaged public var images: Set<EntryImage>?
}

extension EntryPost {
    static func allPostsFetchRequest() -> NSFetchRequest<EntryPost> {
        let request: NSFetchRequest<EntryPost> = EntryPost.fetchRequest() as! NSFetchRequest<EntryPost>
        request.sortDescriptors = [NSSortDescriptor(key: "entryDate", ascending: true)]

        return request
    }
}

extension EntryImage: Identifiable { }

extension EntryImage {
    var uiimage: UIImage {
        return UIImage(data: data!)!
    }
}
