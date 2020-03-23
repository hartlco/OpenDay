import Foundation

public enum WeatherIcon: String {
    case clearDay = "clear-day"
    case clearNight = "clear-night"
    case rain
    case snow
    case sleet
    case wind
    case fog
    case cloudy
    case partlyCloudyDay = "partly-cloudy-day"
    case partlyCloudyNight = "partly-cloudy-night"

    public static func matched(from string: String) -> WeatherIcon? {
        if let icon = WeatherIcon(rawValue: string) {
            return icon
        }

        switch string {
        case _ where string.contains("clear"):
            return .clearDay
        case _ where string.contains("rain"):
            return .rain
        case _ where string.contains("snow"):
            return .snow
        case _ where string.contains("sleet"):
            return .sleet
        case _ where string.contains("wind"):
            return .wind
        case _ where string.contains("fog"):
            return .fog
        case _ where string.contains("partly"):
            return .partlyCloudyDay
        case _ where string.contains("cloudy"):
            return .cloudy
        default:
            return nil
        }
    }
}

public protocol Weather {
    var weatherIcon: WeatherIcon? { get }
    var temperature: Double { get }
}

public extension Weather {
    var temperatureFahrenheit: Double {
        return temperature
    }

    var temperatureCelcius: Double {
          (temperature - 32) * 5 / 9
    }

    static func convertToFahrenheit(from celcius: Double) -> Double {
        celcius * 9 / 5 + 32
    }
}

public extension WeatherIcon {
    var assetName: String {
        switch self {
        case .clearDay:
            return "sun.max"
        case .clearNight:
            return "moon"
        case .cloudy:
            return "cloud"
        case .fog:
            return "cloud.fog"
        case .partlyCloudyDay:
            return "cloud.sun"
        case .partlyCloudyNight:
            return "cloud.moon"
        case .rain:
            return "cloud.rain"
        case .sleet:
            return "cloud.sleet"
        case .snow:
            return "snow"
        case .wind:
            return "wind"
        }
    }
}
