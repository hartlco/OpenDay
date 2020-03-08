import SwiftUI
import KeyboardObserving

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
                        HStack {
                            if (post.images?.count ?? 0) > 0 {
                                VStack {
                                    Image(uiImage: post.images!.first!.uiimage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: 50, maxHeight: 50)
                                        .clipped()
                                    if (post.images?.count ?? 0) > 1 {
                                        Text("More")
                                    }
                                }
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
                        .contextMenu {
                            Button(action: {
                                self.store.delete(entry: post)
                            }, label: {
                                Text("Delete")
                                Image(systemName: "trash")
                            })
                        }
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
