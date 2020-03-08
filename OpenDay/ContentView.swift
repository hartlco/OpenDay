import SwiftUI
import KingfisherSwiftUI
import TextView
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

struct EntryView: View {
    @EnvironmentObject var store: EntryStore

    @State var bodyString = ""
    @State var pickerIsActive: Bool = false
    @State var isEditingContent: Bool = false
    @State var showDateLocationPopup = false

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }

    var body: some View {
        VStack {
            List {
                Section(header: Text("Modify")) {
                    TextField("Title", text: self.$store.title)
                        .font(.headline)
                    NavigationLink(destination: ContentEntryView(bodyString: self.$store.bodyString)) {
                        Text(self.store.bodyString)
                    }
                    DatePicker(selection: self.$store.entryDate,
                               in: Date(timeIntervalSince1970: 0)...,
                               displayedComponents: .date) {
                                Text("Date is \(self.store.entryDate, formatter: dateFormatter)")
                    }
                    ForEach(self.store.images) { entryImage in
                        Image(uiImage: entryImage.uiimage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)

                    }
                    Button(action: {
                        self.pickerIsActive = true
                    }, label: {
                        Text("Import image")
                    })
                    Button(action: {
                        self.store.updateLocation()
                    }, label: {
                        //swiftlint:disable line_length
                        Text("Update Location: \(self.store.currentLocation?.street ?? ""), \(self.store.currentLocation?.city ?? "")")
                    })
                    .sheet(isPresented: $pickerIsActive) {
                        ImagePicker(imagePicked: { imageAsset in
                            self.store.append(imageAsset: imageAsset)
                            self.showDateLocationPopup = true
                        })
                    }
                    .alert(isPresented: self.$showDateLocationPopup) { () -> Alert in
                        Alert(title: Text("Use Location/Date"),
                              primaryButton: .default(Text("Yes"),
                                                      action: {
                                                        self.store.useLastImageAssetsDateAndLocation()
                              }),
                              secondaryButton: .cancel())
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Edit")
            .onDisappear {
                self.store.save()
            }
        }
        .keyboardObserving()
    }
}

struct ContentEntryView: View {
    @Binding var bodyString: String

    var body: some View {
        TextView(text: $bodyString)
        .keyboardObserving()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
