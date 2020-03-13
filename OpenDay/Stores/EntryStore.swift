import Foundation
import CoreData
import UIKit
import LocationService
import CoreLocation
import Combine

final class EntryStore: ObservableObject {
    @Published var images: [EntryImage] = []
    @Published var title = ""
    @Published var bodyString = ""
    @Published var entryDate = Date()
    @Published var currentLocation: Location?

    private var lastInsertedImageAsset: ImageAsset?
    private var entry: EntryPost?

    private let repository: EntryRepository
    private let locationService: LocationService
    private let locale: Locale
    private var locationCancellable: AnyCancellable?
    private var locationFromImageCancellable: AnyCancellable?
    private var searchFromImageCancellable: AnyCancellable?

    init(repository: EntryRepository,
         locale: Locale = .current) {
        self.locationService = LocationService(locationManager: CLLocationManager())
        self.locale = locale
        self.repository = repository
    }

    init(repository: EntryRepository,
         locale: Locale = .current,
         entry: EntryPost) {
        self.entry = entry
        self.images = Array(entry.images ?? [])
        self.title = entry.title ?? ""
        self.bodyString = entry.body ?? ""
        self.entryDate = entry.entryDate ?? Date()
        self.currentLocation = entry.location?.locationServiceLocation
        self.locationService = LocationService(locationManager: CLLocationManager())
        self.locale = locale
        self.repository = repository
    }

    func append(imageAsset: ImageAsset) {
        lastInsertedImageAsset = imageAsset
        let entryImage = repository.newImage()
        entryImage.data = imageAsset.image.jpegData(compressionQuality: 90)
        entryImage.imageDate = imageAsset.creationDate
        images.append(entryImage)
    }

    func updateLocation() {
        locationCancellable = locationService.getLocation().sink(receiveCompletion: { _ in

        }, receiveValue: { [weak self] location in
            guard let self = self else { return }

            self.currentLocation = location
        })
    }

    func useLastImageAssetsDateAndLocation() {
        guard let lastAsset = lastInsertedImageAsset else {
            return
        }

        entryDate = lastAsset.creationDate ?? entryDate

        guard let assetLocation = lastAsset.location else {
            return
        }

        locationFromImageCancellable = locationService.getLocation(from: assetLocation).sink(receiveCompletion: { _ in

        }, receiveValue: { [weak self] location in
            guard let self = self else { return }

            self.currentLocation = location
        })
    }

    func delete(image: EntryImage) {
        guard let index = images.firstIndex(of: image) else {
            return
        }

        images.remove(at: index)
        repository.delete(image: image)
    }

    func save() {
        guard needsToSave else {
            return
        }

        var entry = self.entry

        if entry == nil {
            entry = repository.newEntry()
        }

        entry?.title = self.title
        entry?.body = self.bodyString
        entry?.entryDate = self.entryDate
        entry?.images = Set(self.images)

        if let currentLocation = currentLocation {
            if entry?.location == nil {
                entry?.location = repository.newLocation()
            }

            entry?.location?.update(from: currentLocation)
        }

        repository.save()
    }

    var locationSearchViewModel: LocationSearchViewModel {
        return LocationSearchViewModel(locationService: locationService)
    }

    var locationText: String? {
        guard let currentLocation = currentLocation else {
            return nil
        }

        return currentLocation.localizedString(from: locale)
    }

    private var needsToSave: Bool {
        guard let entry = entry else {
            return true
        }

        if entry.title != title ||
            entry.body != bodyString ||
            entry.entryDate != entryDate ||
            entry.location?.latitude != currentLocation?.latitude ||
            entry.location?.latitude != currentLocation?.latitude ||
            entry.images != Set(images) {
            return true
        }

        return false
    }
}
