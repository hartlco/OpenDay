import Foundation
import CoreData
import UIKit
import LocationService
import CoreLocation
import Combine

final class EntryStore: ObservableObject {
    var entry: EntryPost?

    @Published var images: [EntryImage] = []
    @Published var title = ""
    @Published var bodyString = ""
    @Published var entryDate = Date()
    @Published var currentLocation: Location?

    private var lastInsertedImageAsset: ImageAsset?

    private let managedObjectContext: NSManagedObjectContext
    private let locationService: LocationService
    private var locationCancellable: AnyCancellable?
    private var locationFromImageCancellable: AnyCancellable?

    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.locationService = LocationService(locationManager: CLLocationManager())
    }

    init(managedObjectContext: NSManagedObjectContext,
         entry: EntryPost) {
        self.managedObjectContext = managedObjectContext
        self.entry = entry
        self.images = Array(entry.images ?? [])
        self.title = entry.title ?? ""
        self.bodyString = entry.body ?? ""
        self.entryDate = entry.entryDate ?? Date()
        self.currentLocation = entry.location?.locationServiceLocation
        self.locationService = LocationService(locationManager: CLLocationManager())
    }

    func append(imageAsset: ImageAsset) {
        lastInsertedImageAsset = imageAsset
        let entryImage = EntryImage(context: self.managedObjectContext)
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

    func save() {
        var entry = self.entry

        if entry == nil {
            entry = EntryPost(context: managedObjectContext)
        }

        entry?.title = self.title
        entry?.body = self.bodyString
        entry?.entryDate = self.entryDate
        entry?.images = Set(self.images)

        if let currentLocation = currentLocation {
            if entry?.location == nil {
                entry?.location = EntryLocation(context: managedObjectContext)
            }

            entry?.location?.update(from: currentLocation)
        }

        try? self.managedObjectContext.save()
    }
}
