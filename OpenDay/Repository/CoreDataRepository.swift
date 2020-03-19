import Foundation
import CoreData

final class CoreDataEntryRepository: NSObject, EntryRepository {
    private let context: NSManagedObjectContext
    private let fetchedResultController: NSFetchedResultsController<EntryPost>

    var didChange: (([EntriesSection]) -> Void)?

    init(context: NSManagedObjectContext) {
        self.context = context

        let fetchRequest = CoreDataEntryRepository.allPostsFetchRequest()
        self.fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                   managedObjectContext: context,
                                                                   sectionNameKeyPath: #keyPath(EntryPost.sectionDate),
                                                                   cacheName: "Main")
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

        didChange?(data)
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

    func newWeather() -> EntryWeather {
        EntryWeather(context: context)
    }

    func delete(image: EntryImage) {
        context.delete(image)
    }

    func delete(location: EntryLocation) {
        context.delete(location)
    }

    func delete(weather: EntryWeather) {
        context.delete(weather)
    }

    func delete(entry: EntryPost) {
        let images = entry.images
        let location = entry.location
        let weather = entry.weather
        context.delete(entry)

        if let location = location {
            context.delete(location)
        }

        if let weather = weather {
            context.delete(weather)
        }

        for image in images ?? [] {
            context.delete(image)
        }
    }

    func save() {
        try? context.save()
    }

    private var data: [EntriesSection] {
        guard let sections = fetchedResultController.sections else {
            return []
        }

        return sections.compactMap { sectionInfo in
            guard let data = sectionInfo.objects as? [EntryPost] else {
                return nil
            }

            return EntriesSection(title: sectionInfo.name,
                                  posts: data)
        }
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
        didChange?(data)
    }
}
