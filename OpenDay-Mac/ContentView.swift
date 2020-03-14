import SwiftUI
import OpenKit

struct EntryRowView: View {
    @EnvironmentObject var store: EntriesStore
    let post: EntryPost

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

struct ContentView: View {
    @EnvironmentObject var store: EntriesStore

    var body: some View {
        List() {
            ForEach(store.sections) { section in
                Section(header: Text(section.title)) {
                    ForEach(section.posts) { (post: EntryPost) in
                        EntryRowView(post: post)
                    }
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
