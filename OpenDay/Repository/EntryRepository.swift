import Foundation

final class EntriesSection: Identifiable {
    let title: String
    let posts: [EntryPost]

    init(title: String, posts: [EntryPost]) {
        self.title = title
        self.posts = posts
    }
}

protocol EntryRepository {
    var didChange: (([EntriesSection]) -> Void)? { get set }
    func load()
    func newEntry() -> EntryPost
    func newImage() -> EntryImage
    func newLocation() -> EntryLocation
    func delete(entry: EntryPost)
    func delete(image: EntryImage)
    func delete(location: EntryLocation)
    func save()
}
