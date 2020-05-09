import Foundation
import Models
import OpenDayService

protocol EntryRepository {
    var didChange: (([EntriesSection]) -> Void)? { get set }
    func load()
    func add(entry: Models.Entry)
    func delete(entry: Models.Entry)
    func update(entry: Models.Entry)
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
