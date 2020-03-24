import SwiftUI
import Models
import OpenKit
import MapView
import Kingfisher
import KingfisherSwiftUI

public struct EntryRowView: SwiftUI.View {
    public let post: Models.Post
    public var tapped: () -> Void

    @State var postLocation: [Location]

    public init(post: Models.Post, tapped: @escaping () -> Void) {
        self.post = post
        self.tapped = tapped

        var locations: [Location] = []

        if let postLocation = post.getLocation() {
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
                    Text(EntryRowView.string(from: post.entryDate))
                        .font(Font.caption.smallCaps())
                }
                Text(post.body ?? "")
                    .font(.body)
            }
            .padding([.leading, .trailing], 8.0)
            ScrollView(.horizontal) {
                HStack(spacing: 8.0) {
                    Spacer(minLength: 4)
                    ForEach(post.orderedImages ?? [], id: \Models.Image.id) { image in
                        KFImage(source: .provider(AsyncRawImageDataProvider(image: image)))
                        .resizable()
                        .aspectRatio(contentMode: ContentMode.fill)
                        .frame(width: 120, height: 160)
                        .cornerRadius(8.0)
                        .clipped()
                    }
                    post.getLocation().map { (location: Location) in
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
                    post.getWeather().map { (weather: Weather) in
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

}

/// Represents an image data provider for a raw data object.
struct AsyncRawImageDataProvider: ImageDataProvider {
    let image: Models.Image

    init(image: Models.Image) {
        self.cacheKey = image.id
        self.image = image
    }
    var cacheKey: String

    func data(handler: @escaping (Result<Data, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let data = self.image.thumbnail else {
                handler(.failure(KingfisherError.requestError(reason: .emptyRequest)))
                return
            }

            handler(.success(data))
        }
    }
}
