import Foundation
import CoreData
import Combine
import SwiftUI

final class EntriesStore: ObservableObject {
    private var repository: EntryRepository

    @Published var entries: [EntryPost] = [] {
        willSet {
            objectWillChange.send()
        }
    }
    var objectWillChange = PassthroughSubject<Void, Never>()
    var cancel: AnyCancellable?

    init(repository: EntryRepository) {
        self.repository = repository
        self.repository.didChange = { [weak self] entries in
            guard let self = self else { return }

            self.entries = entries
        }

        repository.load()
    }

    func store(for entry: EntryPost) -> EntryStore {
        return EntryStore(repository: repository, entry: entry)
    }

    func storeForNewEntry() -> EntryStore {
        return EntryStore(repository: repository)
    }

    func delete(entry: EntryPost) {
        repository.delete(entry: entry)
    }
}
