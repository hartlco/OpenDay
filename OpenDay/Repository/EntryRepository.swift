import Foundation
import Models
import OpenDayService

final class EntriesSection: Identifiable {
    let title: String
    let posts: [Entry]

    init(title: String, posts: [Entry]) {
        self.title = title
        self.posts = posts
    }

    var id: String {
        return title
    }
}

protocol EntryRepository {
    var didChange: (([EntriesSection]) -> Void)? { get set }
    func load()

    func add(entry: Models.Entry)
//    func newEntry() -> EntryPost
//    func newImage() -> EntryImage
//    func newLocation() -> EntryLocation
//    func newWeather() -> EntryWeather
//    func delete(entry: EntryPost)
//    func delete(image: EntryImage)
//    func delete(location: EntryLocation)
//    func delete(weather: EntryWeather)
//    func save()
}
