import SwiftUI
import Models

struct WeatherCard: View {
    let weather: Models.Weather

    var body: some View {
        VStack {
            #if os(iOS)
            Image(systemName: weather.weatherSymbol?.assetName ?? "")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40)
            Text(String(weather.temperatureCelcius.rounded(.up)))
                .font(Font.body.bold())
            #elseif os(macOS)
            Image(weather.weatherIcon?.assetName ?? "")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40)
            Text(String(weather.temperatureCelcius.rounded(.up)))
                .font(Font.body.bold())
            #endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(weather.backgroundColor.opacity(0.4))
    }
}

extension Weather {
    var backgroundColor: Color {
        switch weatherSymbol {
        case .clearDay, .partlyCloudyDay:
            return Color.blue
        case .clearNight, .partlyCloudyNight:
            return Color.black
        case .cloudy, .fog, .rain:
            return Color.gray
        case .snow, .wind, .sleet:
            return .white
        case .none:
            return Color.blue
        }
    }
}
