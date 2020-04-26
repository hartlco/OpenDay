import Foundation
import CoreData
import LocationService
import CoreLocation
import Combine
import OpenKit
import Secrets
import WeatherService
import Models

struct ImageAsset {
    let image: OKImage
    let location: CLLocation?
    let creationDate: Date?
}

final class EntryStore: ObservableObject {
    @Published var images: [ImageResource] = []
    @Published var title = ""
    @Published var bodyString = ""
    @Published var entryDate = Date()
    @Published var currentLocation: Models.Location?
    @Published var currentWeather: Weather?

    private var lastInsertedImageAsset: ImageAsset?
    private var entry: Entry?

    private let repository: EntryRepository
    private let locationService: LocationService
    private let locale: Locale
    private var locationCancellable: AnyCancellable?
    private var locationFromImageCancellable: AnyCancellable?
    private var searchFromImageCancellable: AnyCancellable?
    private var weatherServiceCancellable: AnyCancellable?

    init(repository: EntryRepository,
         locale: Locale = .current) {
        self.locationService = LocationService(locationManager: CLLocationManager())
        self.locale = locale
        self.repository = repository

        setupWeatherBinding()
    }

    init(repository: EntryRepository,
         locale: Locale = .current,
         entry: Entry) {
        self.entry = entry
        self.images = entry.images
        self.title = entry.title
        self.bodyString = entry.bodyText
        self.entryDate = entry.date
        self.currentLocation = entry.location
        self.currentWeather = entry.weather
        self.locationService = LocationService(locationManager: CLLocationManager())
        self.locale = locale
        self.repository = repository

        setupWeatherBinding()
    }

    func onAppear() {
        setupWeatherBinding()
    }

    func append(imageAsset: ImageAsset) {
        lastInsertedImageAsset = imageAsset
//        let entryImage = repository.newImage()
//        entryImage.data = imageAsset.image.data
//        entryImage.thumbnail = imageAsset.image.thumbnail
//        entryImage.imageDate = imageAsset.creationDate
        guard let imageData = imageAsset.image.data else {
            return
        }

        let image = ImageResource.local(data: imageData, creationDate: imageAsset.creationDate)
        images.append(image)
    }

    func updateLocation() {
        locationCancellable = locationService.getLocation().receive(on: RunLoop.main).sink(receiveCompletion: { _ in

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

        locationFromImageCancellable = locationService.getLocation(from: assetLocation)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in

            }, receiveValue: { [weak self] location in
                guard let self = self else { return }

                self.currentLocation = location
            })
    }

    func delete(image: ImageResource) {
        guard let index = images.firstIndex(of: image) else {
            return
        }

        images.remove(at: index)
    }

    func save() {
        guard needsToSave else {
            return
        }

        if entry == nil {
            let entry = Models.Entry(title: title,
                                     bodyText: bodyString,
                                     date: entryDate,
                                     images: images,
                                     location: currentLocation,
                                     weather: currentWeather)

            repository.add(entry: entry)
            return
        }

        let newEntry = Entry(id: entry?.id,
                             title: title,
                             bodyText: bodyString,
                             date: entryDate,
                             images: images,
                             location: currentLocation,
                             weather: currentWeather)
        repository.update(entry: newEntry)
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
            entry.bodyText != bodyString ||
            entry.date != entryDate ||
            entry.location?.coordinates.latitude != currentLocation?.coordinates.latitude ||
            entry.location?.coordinates
                .latitude != currentLocation?.coordinates.latitude ||
            entry.images != images {
            return true
        }

        return false
    }

    private func setupWeatherBinding() {
        weatherServiceCancellable = $currentLocation.compactMap { location in
            return location
        }
        .setFailureType(to: Error.self)
        .combineLatest($entryDate.setFailureType(to: Error.self))
        .flatMap { (data: (Location, Date)) in
            return WeatherService().getData(key: Secrets.darkSkyKey,
                                            date: data.1,
                                            latitude: data.0.coordinates.latitude,
                                            longitude: data.0.coordinates.longitude)
                .catch { _ in
                    Empty<WeatherService.WeatherData, Error>()
            }
        }
        .sink(receiveCompletion: { _ in

        }, receiveValue: { [weak self] weatherData in
            guard let self = self else { return }

            self.currentWeather = Weather(weatherSymbol: WeatherIcon.matched(from: weatherData.icon.rawValue),
                                          fahrenheit: Int(weatherData.temperatureFahrenheit))
        })
    }
}
