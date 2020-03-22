import SwiftUI
import KeyboardObserving
import EntryRowView
import MapView
import Models

struct ContentView: View {
    @EnvironmentObject var store: EntriesStore

    @State var isModal: Bool = false
    @State var selectedModalEntry: Post?

    var modal: some View {
        Text("Modal")
    }

    func tapGesture(for post: Post) -> some Gesture {
        return TapGesture().onEnded {
            self.isModal = true
            self.selectedModalEntry = post
        }
    }

    var mapView: some View {
        return MapView(locations: $store.locations) { location in
            self.isModal = true
            self.selectedModalEntry = location.getPost()
        }.edgesIgnoringSafeArea(.vertical)
    }

    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.vertical) {
                    VStack(alignment: .leading) {
                        ForEach(store.sections) { (section: EntriesSection) in
                            Text(section.title)
                                .font(Font.title.smallCaps()).bold()
                                .padding()
                            ForEach(section.posts) { (post: EntryPost) in
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
                    NavigationLink(destination: mapView.sheet(isPresented: $isModal, content: {
                        self.selectedModalEntry.map { post in
                            EntryView().environmentObject(self.store.store(for: post))
                        }
                    })) {
                        Image(systemName: "map")
                        .resizable()
                        .frame(width: 32.0, height: 32.0, alignment: .center)
                        .padding()
                    }
                    Spacer()
                }
            }
            .navigationBarTitle("Entries")
        }
    }
}
