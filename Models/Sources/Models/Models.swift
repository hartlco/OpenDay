import Foundation

public protocol Post: class {
    var title: String? { get set }
    var body: String? { get set }
    var entryDate: Date? { get set }
    var orderedImages: [Image]? { get }

    func getLocation() -> Location?
}

public protocol Image: class {
    var data: Data? { get set }
    var imageDate: Date? { get set }
}

public protocol Location: class {
    var city: String? { get set}
    var isoCountryCode: String? { get set}
    var latitude: Double { get set}
    var longitude: Double { get set}
    var street: String? { get set}
}
