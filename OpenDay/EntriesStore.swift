import Foundation
import CoreData
import Combine
import SwiftUI
import Models

final class EntriesStore: ObservableObject {
    private var repository: EntryRepository
    private let dateFormatter: DateFormatter

    @Published var sections: [EntriesSection] = [] {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var locations: [Location] = [] {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var selection: Entry?

    var objectWillChange = PassthroughSubject<Void, Never>()

    init(repository: EntryRepository) {
        self.dateFormatter = DateFormatter()
        self.repository = repository
        self.repository.didChange = { [weak self] entries in
            guard let self = self else { return }

            self.sections = entries

            self.locations = entries.map {
                return $0.entries
            }.flatMap {
                return $0
            }.compactMap { post in
                return post.location
            }
        }

        repository.load()
        dateFormatter.dateFormat = "EEE dd"
    }

    func store(for entry: Entry) -> EntryStore {
        return EntryStore(repository: repository, entry: entry)
    }

    func storeForNewEntry() -> EntryStore {
        return EntryStore(repository: repository)
    }

    func delete(entry: Models.Entry) {
        repository.delete(entry: entry)
    }

    func deleteAll() {
//        for section in sections {
//            for entry in section.posts {
//                delete(entry: entry)
//            }
//        }
    }

    var hasSelectedEntry: Bool {
        return selection != nil
    }

    func deleteSelectedEntry() {
        guard let selectedEntry = selection else {
            return
        }

        delete(entry: selectedEntry)
        selection = nil
    }
}
