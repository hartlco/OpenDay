import Foundation
import CoreData
import UIKit

final class EntryStore: ObservableObject {
    var entry: EntryPost?

    @Published var images: [EntryImage] = []
    @Published var title = ""
    @Published var bodyString = ""
    @Published var entryDate = Date()

    private let managedObjectContext: NSManagedObjectContext

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
    }

    init(managedObjectContext: NSManagedObjectContext,
         entry: EntryPost) {
        self.managedObjectContext = managedObjectContext
        self.entry = entry
        self.images = Array(entry.images ?? [])
        self.title = entry.title ?? ""
        self.bodyString = entry.body ?? ""
        self.entryDate = entry.entryDate ?? Date()
    }

    func append(image: UIImage) {
        let entryImage = EntryImage(context: self.managedObjectContext)
        entryImage.data = image.jpegData(compressionQuality: 90)
        entryImage.imageDate = Date()
        images.append(entryImage)
    }

    func save() {
        var entry = self.entry

        if entry == nil {
            entry = EntryPost(context: self.managedObjectContext)
        }

        entry?.title = self.title
        entry?.body = self.bodyString
        entry?.entryDate = self.entryDate
        entry?.images = Set(self.images)
        try? self.managedObjectContext.save()
    }
}
