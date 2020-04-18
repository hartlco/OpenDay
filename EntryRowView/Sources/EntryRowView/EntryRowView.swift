import SwiftUI
import Models
import OpenKit
import MapView
import Kingfisher
import KingfisherSwiftUI
import OpenDayService

public struct EntryRowView: SwiftUI.View {
    public let post: Entry
    public var tapped: () -> Void

    @State var postLocation: [Location]

    public init(post: Entry, tapped: @escaping () -> Void) {
        self.post = post
        self.tapped = tapped

        var locations: [Location] = []

        if let postLocation = post.location {
            locations.append(postLocation)
        }

        self._postLocation = State<[Location]>(initialValue: locations)
    }

    public var body: some SwiftUI.View {
        VStack(alignment: HorizontalAlignment.leading) {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text(post.title ?? "")
                        .font(.system(.headline, design: .rounded))
                        .bold()
                    Spacer()
                    Text(EntryRowView.string(from: post.date))
                        .font(Font.caption.smallCaps())
                }
                Text(post.bodyText ?? "")
                    .font(.body)
            }
            .padding([.leading, .trailing], 8.0)
            ScrollView(.horizontal) {
                HStack(spacing: 8.0) {
                    Spacer(minLength: 4)
                    ForEach(post.images) { image in
                        self.image(for: image)
                        .resizable()
                        .aspectRatio(contentMode: ContentMode.fill)
                        .frame(width: 120, height: 160)
                        .cornerRadius(8.0)
                        .clipped()
                    }
                    post.location.map { (location: Location) in
                        ZStack {
                            MapView(locations: $postLocation,
                                    userInteractionEnabled: false)
                            VStack {
                                Spacer()
                                Text(location.city ?? "")
                                    .font(Font.caption.bold())
                                    .frame(maxWidth: .infinity)
                                    .background(Color.secondary.colorInvert().opacity(0.8))
                            }
                        }
                        .cornerRadius(8.0)
                        .frame(width: 120, height: 160)
                    }
                    post.weather.map { (weather: Weather) in
                        WeatherCard(weather: weather)
                        .cornerRadius(8.0)
                        .frame(width: 120, height: 160)
                    }
                    Spacer(minLength: 4)
                }
                .padding(.bottom, 14.0)
                .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.tapped()
        }
    }

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE dd"
        return dateFormatter
    }()

    private static func string(from date: Date?) -> String {
        guard let date = date else {
            return ""
        }

        return dateFormatter.string(from: date)
    }

    private func image(for resource: Models.ImageResource) -> KFImage {
        switch resource {
        case .local(let data, _):
            return KFImage(source: .provider(AsyncRawImageDataProvider(data: data)))
        case .remote(let url):
            return KFImage(url)
        }
    }

}

/// Represents an image data provider for a raw data object.
struct AsyncRawImageDataProvider: ImageDataProvider {
    let data: Data

    init(data: Data) {
        self.cacheKey = String(data.hashValue)
        self.data = data
    }
    var cacheKey: String

    func data(handler: @escaping (Result<Data, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            handler(.success(self.data))
        }
    }
}
