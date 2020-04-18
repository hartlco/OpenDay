import Foundation

public struct Entry: Codable, Identifiable {
    //swiftlint:disable identifier_name
    public let id: String?
    public let title: String
    public let date: Date
    public let images: [ImageResource]
    public let location: Location?
    public let weather: Weather?

    let body: String

    public init(title: String,
                bodyText: String,
                date: Date,
                images: [ImageResource] = [],
                location: Location? = nil,
                weather: Weather? = nil) {
        self.id = nil
        self.title = title

        let base64Data = bodyText.data(using: .utf8)
        let base64String = base64Data?.base64EncodedString()

        self.body = base64String ?? ""

        self.date = date
        self.images = images
        self.location = location
        self.weather = weather
    }

    public var bodyText: String {
        guard let data = Data(base64Encoded: body) else {
            return ""
        }

        return String(data: data, encoding: .utf8) ?? ""
    }
}

public enum ImageResource: Codable, Identifiable {
    case remote(url: URL)
    case local(data: Data, creationDate: Date?)

    enum CodingError: Error {
        case decoding(String)
    }

    public init(from decoder: Decoder) throws {
        let value = try? decoder.singleValueContainer()
        if let url = try? value?.decode(URL.self) {
            self = .remote(url: url)
            return
        } else if let data = try? value?.decode(Data.self) {
            self = .local(data: data, creationDate: nil)
            return
        }

        throw CodingError.decoding("ImageResource couldn't be decoded")
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .local(let data, _):
            try? container.encode(data)
        case .remote(let url):
            try? container.encode(url)
        }
    }

    public var id: Int {
        switch self {
        case .local(let data, _):
            return data.hashValue
        case .remote(let url):
            return url.hashValue
        }
    }
}

public protocol Post: class {
    var title: String? { get set }
    var body: String? { get set }
    var entryDate: Date? { get set }
    var orderedImages: [Image]? { get }

    func getLocation() -> Location?
    func getWeather() -> Weather?
}

public protocol Image: class {
    var data: Data? { get set }
    var thumbnail: Data? { get set }
    var imageDate: Date? { get set }
    var id: String { get }
}

public struct Location: Codable, Identifiable {
    public struct Coordinates: Codable {
        public let longitude: Double
        public let latitude: Double
        
        public init(longitude: Double, latitude: Double) {
            self.longitude = longitude
            self.latitude = latitude
        }
    }

    //swiftlint:disable identifier_name
    public var id: String {
        return "\(coordinates.longitude)-\(coordinates.latitude)"
    }

    public init(coordinates: Location.Coordinates,
                isoCountryCode: String,
                city: String?,
                name: String?) {
        self.coordinates = coordinates
        self.isoCountryCode = isoCountryCode
        self.city = city
        self.name = name
    }

    public let coordinates: Coordinates
    public let isoCountryCode: String
    public let city: String?
    public let name: String?

    public func localizedString(from locale: Locale) -> String {
        let values = [
            name,
            city,
            locale.localizedString(forRegionCode: isoCountryCode)
        ]

        return values.compactMap {
            $0
        }.joined(separator: ", ")
    }
}
