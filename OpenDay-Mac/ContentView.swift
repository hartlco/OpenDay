import SwiftUI
import OpenKit
import EntryRowView

struct ContentView: View {
    @EnvironmentObject var store: EntriesStore

    var body: some View {
        List {
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
