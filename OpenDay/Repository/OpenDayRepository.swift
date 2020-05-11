import Foundation
import Combine
import OpenDayService
import Models

final class OpenDayRepository: EntryRepository {
    private var loadCancellable: AnyCancellable?
    private var addCancellable: AnyCancellable?
    private var deleteCancellable: AnyCancellable?
    private var updateCancellable: AnyCancellable?

    var didChange: (([EntriesSection]) -> Void)?

    private let client: Client
    private let openDayService: OpenDayService

    init(client: Client) {
        self.client = client

        self.openDayService = OpenDayService(baseURL: URL(string: "http://192.168.10.50:8000")!,
                                             client: client)
    }

    func load() {
        let future: Future<[EntriesSection], Error> = openDayService.perform(endpoint: .entries)

        loadCancellable = future.sink(receiveCompletion: { _ in

        }, receiveValue: { [weak self] entries in
            guard let self = self else { return }

            self.didChange?(entries)
        })
    }

    func add(entry: Entry) {
        let future: Future<String, Error> = openDayService.perform(endpoint: .createEntry(entry))

        addCancellable = future.sink(receiveCompletion: { _ in

        }, receiveValue: { okString in
            print("Add: \(okString)")
        })
    }

    func delete(entry: Entry) {
        let future: Future<String, Error> = openDayService.perform(endpoint: .deleteEntry(entry))

        deleteCancellable = future.sink(receiveCompletion: { _ in

        }, receiveValue: { okString in
            print("Delete: \(okString)")
        })
    }

    func update(entry: Entry) {
        let future: Future<String, Error> = openDayService.perform(endpoint: .updateEntry(entry))

        updateCancellable = future.sink(receiveCompletion: { _ in

        }, receiveValue: { okString in
            print("Update: \(okString)")
        })
    }
}
