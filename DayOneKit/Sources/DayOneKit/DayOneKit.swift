import Foundation

public struct Import: Codable {
    public let entries: [Entry]
}

public struct Entry: Codable {
    static let imageRegex = NSRegularExpression("""
        (?:!\\[(.*?)\\]\\((.*?)\\))
    """)

    static let dateFormatter = ISO8601DateFormatter()

    public let creationDate: String
    public let text: String?
    public let location: Location?
    public let photos: [Photo]?
    public let weather: Weather?

    var cleanedText: String? {
        guard let text = text else {
            return nil
        }

        let mutableString = NSMutableString(string: text)

        let range = NSRange(location: 0, length: mutableString.length)
        Entry.imageRegex.replaceMatches(in: mutableString, options: [], range: range, withTemplate: "")
        return mutableString as String
    }

    public var title: String {
        guard let text = text else {
            return ""
        }

        let splits = text.split(separator: "\n", maxSplits: 2, omittingEmptySubsequences: true)

        if splits.count > 1 {
            return String(splits[0])
        }

        return ""
    }

    public var body: String {
        guard let text = cleanedText else {
            return ""
        }

        let splits = text.split(separator: "\n", maxSplits: 2, omittingEmptySubsequences: true)

        if splits.count > 1 {
            return String(splits[1])
        }

        return ""
    }

    public var convertedDate: Date? {
        return Entry.dateFormatter.date(from: creationDate)
    }
}

public struct Location: Codable {
    public let longitude: Double?
    public let latitude: Double?
    public let placeName: String?
    public let administrativeArea: String?
    public let country: String?

    public var countryCode: String? {
        guard let country = country else {
            return nil
        }

        return isoCountryCode(for: country)
    }
}

public struct Weather: Codable {
    public let weatherCode: String
    public let temperatureCelsius: Int
}

public struct Photo: Codable {
    let type: String
    let md5: String

    public func fileURL(for exportFolder: URL) -> URL {
        return exportFolder.appendingPathComponent("photos/\(md5).\(type)")
    }
}

public class DayOneKitDataReader {
    let fileURL: URL

    private let fileManager: FileManager

    public init(fileURL: URL,
                fileManager: FileManager = .default) {
        self.fileURL = fileURL
        self.fileManager = fileManager
    }

    public func importedData(for journalName: String) -> Import {
        //swiftlint:disable force_try
        let data = try! Data(contentsOf: fileURL.appendingPathComponent("\(journalName).json"))
        //swiftlint:disable force_try
        let importedData = try! JSONDecoder().decode(Import.self, from: data)
        return importedData
    }
}

extension NSRegularExpression {
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern, options: [.anchorsMatchLines, .allowCommentsAndWhitespace])
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
}

func isoCountryCode(for englishCountryName: String) -> String? {
    for localeCode in NSLocale.isoCountryCodes {
        let countryName = NSLocale(localeIdentifier: "en-US").displayName(forKey: NSLocale.Key.countryCode, value: localeCode)
        if englishCountryName.lowercased() == countryName?.lowercased() {
            return localeCode
        }
    }

    return nil
}
