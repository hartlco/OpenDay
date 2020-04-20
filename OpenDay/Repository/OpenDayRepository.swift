import Foundation
import Combine
import OpenDayService
import Models

final class OpenDayRepository: EntryRepository {
    private var loadCancellable: AnyCancellable?
    private var addCancellable: AnyCancellable?
    private var deleteCancellable: AnyCancellable?

    var didChange: (([EntriesSection]) -> Void)?

    private let openDayService = OpenDayService(baseURL: URL(string: "http://192.168.10.26:8000")!,
                                                urlSession: .shared)

    func load() {
        let future: Future<[Entry], Error> = openDayService.perform(endpoint: .entries)

        loadCancellable = future.sink(receiveCompletion: { _ in

        }, receiveValue: { [weak self] entries in
            guard let self = self else { return }

            let section = EntriesSection(title: "March", posts: entries)
            self.didChange?([section])
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

    func newEntry() -> EntryPost {
        fatalError()
    }

    func newImage() -> EntryImage {
        fatalError()
    }

    func newLocation() -> EntryLocation {
        fatalError()
    }

    func newWeather() -> EntryWeather {
        fatalError()
    }

    func delete(entry: EntryPost) {
        fatalError()
    }

    func delete(image: EntryImage) {
        fatalError()
    }

    func delete(location: EntryLocation) {
        fatalError()
    }

    func delete(weather: EntryWeather) {
        fatalError()
    }

    func save() {
        fatalError()
    }


}
