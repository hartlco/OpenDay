import SwiftUI
import KeyboardObserving

struct EntryCellContent: View {
    let post: EntryPost

    var body: some View {
        HStack {
            if (post.images?.count ?? 0) > 0 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(self.post.images ?? [])) { entryImage in
                            Image(uiImage: entryImage.uiimage)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: 50, maxHeight: 50)
                        }
                    }
                }
                .frame(maxWidth: 70)
            }
            VStack(alignment: .leading) {
                Text(post.title ?? "")
                    .font(.headline)
                Text(post.body ?? "")
                    .font(.footnote)
                    .lineLimit(2)
                Text(post.entryDate?.description ?? "")
                    .font(.caption)
            }
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var store: EntriesStore
    @FetchRequest var posts: FetchedResults<EntryPost>

    init() {
        self._posts = FetchRequest(fetchRequest: EntriesStore.allPostsFetchRequest())
    }

    var body: some View {
        NavigationView {
            VStack {
                List(posts) { post in
                    NavigationLink(destination: EntryView().environmentObject(self.store.store(for: post))) {
                        EntryCellContent(post: post)
                    }
                }
                .listStyle(GroupedListStyle())
                HStack {
                    Spacer()
                    NavigationLink(destination: EntryView().environmentObject(store.storeForNewEntry()),
                                   label: {
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .frame(width: 32.0, height: 32.0, alignment: .center)
                                        .padding()
                    })
                    Spacer()
                }
            }
            .navigationBarTitle("Entries")
        }
    }
}
