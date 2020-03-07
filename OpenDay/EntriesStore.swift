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
        let request: NSFetchRequest<EntryPost> = EntryPost.fetchRequest() as! NSFetchRequest<EntryPost>
        request.sortDescriptors = [NSSortDescriptor(key: "entryDate", ascending: true)]

        return request
    }

    func store(for entry: EntryPost) -> EntryStore {
        return EntryStore(managedObjectContext: managedObjectContext, entry: entry)
    }

    func storeForNewEntry() -> EntryStore {
        return EntryStore(managedObjectContext: managedObjectContext)
    }
}
