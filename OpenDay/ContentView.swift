import SwiftUI
import KeyboardObserving
import EntryRowView
import MapView
import Models
import KingfisherSwiftUI
import OpenDayService

struct ContentView: View {
    @EnvironmentObject var store: EntriesStore

    @State var isModal: Bool = false
    @State var selectedModalEntry: Entry?

    var modal: some View {
        Text("Modal")
    }

    func tapGesture(for post: Entry) -> some Gesture {
        return TapGesture().onEnded {
            self.isModal = true
            self.selectedModalEntry = post
        }
    }

    var mapView: some View {
        return MapView(locations: $store.locations) { location in
            self.isModal = true
            //            self.selectedModalEntry = location.getPost()
        }.edgesIgnoringSafeArea(.vertical)
    }

    var body: some View {
        NavigationView {
            TabView {
                contentList
                    .tabItem {
                        Image(systemName: "house")
                        Text("Entries")
                }
                mapView
                    .tabItem {
                        Image(systemName: "map")
                        Text("Map")
                }
            }
            .navigationBarItems(trailing: addButton)
            .navigationBarTitle("Entries")
        }
    }

    var contentList: some View {
        List {
            ForEach(store.sections) { (section: EntriesSection) in
                Text(section.title)
                    .font(Font.title.smallCaps()).bold()
                ForEach(section.entries) { (post: Entry) in
                    EntryRowView(post: post) {
                        self.isModal = true
                        self.selectedModalEntry = post
                    }
                    .sheet(isPresented: self.$isModal, content: {
                        self.selectedModalEntry.map { post in
                            NavigationView {
                                EntryView().environmentObject(self.store.store(for: post))
                            }
                        }
                    })
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
        .listStyle(DefaultListStyle())
    }

    var addButton: some View {
        NavigationLink(destination: EntryView().environmentObject(store.storeForNewEntry()),
                       label: {
                        Image(systemName: "plus.circle.fill")
        })
    }
}
