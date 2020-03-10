import Foundation

protocol EntryRepository {
    var didChange: (([EntryPost]) -> Void)? { get set }
    func load()
    func newEntry() -> EntryPost
    func newImage() -> EntryImage
    func newLocation() -> EntryLocation
    func delete(entry: EntryPost)
    func delete(image: EntryImage)
    func delete(location: EntryLocation)
    func save()
}
