import SwiftUI
import OpenKit

struct EntryListContent: View {
    @EnvironmentObject var store: EntriesStore
    let post: EntryPost

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline) {
                    Text(post.title ?? "")
                        .font(.headline)
                    Spacer()
                    Text(store.dateString(for: post))
                        .font(Font.caption.smallCaps())
                }
                Text(post.body ?? "")
                    .font(.body)
                    .lineLimit(4)
            }
            if (post.images?.count ?? 0) > 0 {
                Image(uiImage: post.images!.first!.openImage)
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fill)
                    .frame(maxHeight: 160)
                    .cornerRadius(4.0)
                    .clipped()
            }
        }
    }
}
