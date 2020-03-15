import SwiftUI
import OpenKit
import EntryRowView

struct DetailView: View {
    let text: String

    var body: some View {
        Text(text)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView: View {
    @EnvironmentObject var store: EntriesStore

    var body: some View {
        NavigationView {
            List {
                ForEach(store.sections) { section in
                    Section(header: Text(section.title)) {
                        ForEach(section.posts) { (post: EntryPost) in
                            NavigationLink(destination: DetailView(text: post.title ?? "")) {
                                EntryRowView(post: post)
                            }
                            .navigationViewStyle(DoubleColumnNavigationViewStyle())
                            .contextMenu {
                                Button(action: {
                                    self.store.delete(entry: post)
                                }, label: {
                                    Text("Delete")
                                })
                            }
                            .menuButtonStyle(BorderlessButtonMenuButtonStyle())
                        }
                    }
                }
            }
            .frame(minWidth: 380, maxWidth: 480)
            DetailView(text: "")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
