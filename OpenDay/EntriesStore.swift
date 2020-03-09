import Foundation
import CoreData
import Combine
import SwiftUI

final class EntriesStore: ObservableObject {
    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    static func allPostsFetchRequest() -> NSFetchRequest<EntryPost> {
        //swiftlint:disable force_cast
        let request: NSFetchRequest<EntryPost> = EntryPost.fetchRequest() as! NSFetchRequest<EntryPost>
        request.sortDescriptors = [NSSortDescriptor(key: "entryDate", ascending: false)]

        return request
    }

    func store(for entry: EntryPost) -> EntryStore {
        return EntryStore(managedObjectContext: managedObjectContext, entry: entry)
    }

    func storeForNewEntry() -> EntryStore {
        return EntryStore(managedObjectContext: managedObjectContext)
    }

    func delete(entry: EntryPost) {
        let images = entry.images
        let location = entry.location
        managedObjectContext.delete(entry)

        if let location = location {
            managedObjectContext.delete(location)
        }

        for image in images ?? [] {
            managedObjectContext.delete(image)
        }
    }
}
