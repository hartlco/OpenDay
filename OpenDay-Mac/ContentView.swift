import SwiftUI
import OpenKit
import EntryRowView
import MapView
import Models

struct DetailView: View {
    let post: Entry

    var body: some View {
        VStack {
            Text(post.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Text(post.bodyText)
            Text(post.weather?.weatherSymbol?.rawValue ?? "")
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var store: EntriesStore

    var body: some View {
        NavigationView {
            List {
                ForEach(store.sections) { section in
                    Section(header: Text(section.title)) {
                        ForEach(section.posts) { (post: Entry) in
                            NavigationLink(destination: DetailView(post: post)) {
                                EntryRowView(post: post) {

                                }
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
            .navigationViewStyle(DoubleColumnNavigationViewStyle())
            MapView(locations: $store.locations)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
