import SwiftUI
import Models
import OpenKit
import MapView

public struct EntryRowView: View {
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

    public var body: some View {
        VStack(alignment: .leading) {
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
                    .lineLimit(4)
            }
            ScrollView(.horizontal) {
                HStack(spacing: 12.0) {
                    ForEach(post.orderedImages ?? [], id: \Models.Image.id) { image in
                        Image(okImageData: image.data!)
                        .resizable()
                        .aspectRatio(contentMode: ContentMode.fill)
                        .frame(width: 120, height: 160)
                        .cornerRadius(8.0)
                        .clipped()
                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
                    }
                    post.getLocation().map { _ in
                        MapView(locations: $postLocation)
                        .frame(width: 120, height: 160)
                        .cornerRadius(8.0)
                        .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 4)
                    }
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.tapped()
        }
        .padding(12.0)
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
