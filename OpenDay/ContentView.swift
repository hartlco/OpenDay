import SwiftUI
import KeyboardObserving
import EntryRowView

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
                                    EntryRowView(post: post)
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
