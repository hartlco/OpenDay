import SwiftUI
import Models
import OpenKit

public struct EntryRowView: View {
    public let post: Models.Post

    public init(post: Models.Post) {
        self.post = post
    }

    public var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline) {
                    Text(post.title ?? "")
                        .font(Font.headline.smallCaps())
                        .bold()
                    Spacer()
                    Text(EntryRowView.string(from: post.entryDate))
                        .font(Font.caption.smallCaps())
                }
                Text(post.body ?? "")
                    .font(.body)
                    .lineLimit(4)
            }
            if (post.orderedImages?.count ?? 0) > 0 {
                post.orderedImages!.first?.thumbnail.map({ data in
                    Image(okImageData: data)
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fill)
                    .frame(maxHeight: 160)
                    .cornerRadius(4.0)
                    .clipped()
                })
            }
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
