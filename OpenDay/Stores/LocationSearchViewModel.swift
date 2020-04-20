import Foundation
import LocationService
import Combine
import Models

final class LocationSearchViewModel: ObservableObject {
    @Published var searchText: String = "" {
        willSet {
            if newValue == "" {
                locations = []
            }
        }
    }
    @Published var locations = [Location]()

    private var throttleCancellable: AnyCancellable?
    private var loadLocationsCancellable: AnyCancellable?

    private let locationService: LocationService
    private let locale: Locale

    init(locationService: LocationService,
         locale: Locale = .current) {
        self.locationService = locationService
        self.locale = locale

        loadLocationsCancellable = $searchText
            .debounce(for: .seconds(0.8), scheduler: RunLoop.main)
            .setFailureType(to: Error.self)
            .flatMap({ [unowned self] (text) -> Future<[Location], Error> in
                return self.locationService.getLocations(from: text)
            })
            .sink(receiveCompletion: { _ in

            }, receiveValue: { [unowned self] locations in
                self.locations = locations
            })
    }

    func text(for location: Models.Location) -> String {
        return location.localizedString(from: locale)
    }
}
