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

    var objectWillChange = PassthroughSubject<Void, Never>()

    init(repository: EntryRepository) {
        self.dateFormatter = DateFormatter()
        self.repository = repository
        self.repository.didChange = { [weak self] entries in
            guard let self = self else { return }

            self.sections = entries

            self.locations = entries.map {
                return $0.posts
            }.flatMap {
                return $0
            }.compactMap { post in
                return post.location
            }
        }

        repository.load()
        dateFormatter.dateFormat = "EEE dd"
    }

    func store(for entry: Post) -> EntryStore {
        guard let entry = entry as? EntryPost else {
            fatalError("Missmatched Typed")
        }

        return EntryStore(repository: repository, entry: entry)
    }

    func storeForNewEntry() -> EntryStore {
        return EntryStore(repository: repository)
    }

    func delete(entry: EntryPost) {
        repository.delete(entry: entry)
    }
}
