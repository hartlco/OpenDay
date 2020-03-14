import SwiftUI
import OpenKit
import Models

struct EntryListContent: View {
    @EnvironmentObject var store: EntriesStore
    let post: Models.Post

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline) {
                    Text(post.title ?? "")
                        .font(.headline)
                    Spacer()
                    Text(store.dateString(for: post.entryDate))
                        .font(Font.caption.smallCaps())
                }
                Text(post.body ?? "")
                    .font(.body)
                    .lineLimit(4)
            }
            if (post.orderedImages?.count ?? 0) > 0 {
                Image(okImage: post.orderedImages!.first!.openImage)
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fill)
                    .frame(maxHeight: 160)
                    .cornerRadius(4.0)
                    .clipped()
            }
        }
    }
}
