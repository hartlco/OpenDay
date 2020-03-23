import SwiftUI
import Models

struct WeatherCard: View {
    let weather: Models.Weather

    var body: some View {
        VStack {
            Image(systemName: weather.weatherIcon?.assetName ?? "")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40, height: 40)
            Text(String(weather.temperatureCelcius.rounded(.up)))
                .font(Font.body.bold())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(weather.backgroundColor.opacity(0.4))
    }
}

extension Weather {
    var backgroundColor: Color {
        switch weatherIcon {
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
