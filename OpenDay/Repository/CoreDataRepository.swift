import Foundation
import CoreData

final class CoreDataEntryRepository: NSObject, EntryRepository {
    private let context: NSManagedObjectContext
    private let fetchedResultController: NSFetchedResultsController<EntryPost>

    var didChange: (([EntryPost]) -> Void)?

    init(context: NSManagedObjectContext) {
        self.context = context

        let fetchRequest = CoreDataEntryRepository.allPostsFetchRequest()
        self.fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: context,
                                                                   sectionNameKeyPath: nil, cacheName: nil)
        super.init()
        fetchedResultController.delegate = self
    }

    func load() {
        do {
          try fetchedResultController.performFetch()
        } catch {
          let nserror = error as NSError
          fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }

        if let fetchedObjects = fetchedResultController.fetchedObjects {
            didChange?(fetchedObjects)
        }
    }

    func newEntry() -> EntryPost {
        EntryPost(context: context)
    }

    func newImage() -> EntryImage {
        EntryImage(context: context)
    }

    func newLocation() -> EntryLocation {
        EntryLocation(context: context)
    }

    func delete(image: EntryImage) {
        context.delete(image)
    }

    func delete(location: EntryLocation) {
        context.delete(location)
    }

    func delete(entry: EntryPost) {
        let images = entry.images
        let location = entry.location
        context.delete(entry)

        if let location = location {
            context.delete(location)
        }

        for image in images ?? [] {
            context.delete(image)
        }
    }

    func save() {
        try? context.save()
    }

    static func allPostsFetchRequest() -> NSFetchRequest<EntryPost> {
        //swiftlint:disable force_cast
        let request: NSFetchRequest<EntryPost> = EntryPost.fetchRequest() as! NSFetchRequest<EntryPost>
        request.sortDescriptors = [NSSortDescriptor(key: "entryDate", ascending: false)]

        return request
    }
}

extension CoreDataEntryRepository: NSFetchedResultsControllerDelegate {
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    //swiftlint:disable force_cast
    let entries = controller.sections![0].objects as! [EntryPost]
    didChange?(entries)
  }
}
