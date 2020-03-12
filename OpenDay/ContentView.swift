import SwiftUI
import KeyboardObserving

struct ContentView: View {
    @EnvironmentObject var store: EntriesStore

    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(store.sections) { (section: EntriesSection) in
                        Section(header: Text(section.title)) {
                            ForEach(section.posts) { (post: EntryPost) in
                                //swiftlint:disable line_length
                                NavigationLink(destination: EntryView().environmentObject(self.store.store(for: post))) {
                                    VStack(alignment: .leading) {
                                        VStack(alignment: .leading) {
                                            Text(post.title ?? "")
                                                .font(.headline)
                                            Text(post.body ?? "")
                                                .font(.body)
                                                .lineLimit(4)
                                            Text(post.entryDate?.description ?? "")
                                                .font(.caption)
                                        }
                                        if (post.images?.count ?? 0) > 0 {
                                            Image(uiImage: post.images!.first!.uiimage)
                                                .resizable()
                                                .scaledToFit()
                                                .aspectRatio(contentMode: ContentMode.fill)
                                                .frame(maxHeight: 140)
                                                .clipped()
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
                        }
                    }
                }
                .listStyle(DefaultListStyle())
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
