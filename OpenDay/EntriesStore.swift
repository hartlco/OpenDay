import Foundation
import CoreData
import Combine
import SwiftUI

final class EntriesStore: ObservableObject {
    private var repository: EntryRepository
    private let dateFormatter: DateFormatter

    @Published var sections: [EntriesSection] = [] {
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
        }

        repository.load()
        dateFormatter.dateFormat = "EEE dd"
    }

    func dateString(for entry: EntryPost) -> String {
        guard let date = entry.entryDate else {
            return ""
        }

        return dateFormatter.string(from: date)
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
