import SwiftUI
import KingfisherSwiftUI
import TextView
import KeyboardObserving

struct ContentView: View {
    @FetchRequest(fetchRequest: EntryPost.allPostsFetchRequest()) var posts: FetchedResults<EntryPost>

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: EntryView(),
                               label: {
                                Text("Add")
                })
                List(posts) { post in
                    NavigationLink(destination: EntryView(entry: post)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(post.title ?? "")
                                    .font(.headline)
                                Text(post.body ?? "")
                                Text(post.entryDate?.description ?? "")
                                    .font(.footnote)
                            }
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(Array(post.images ?? [])) { entryImage in
                                        Image(uiImage: entryImage.uiimage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxHeight: 50)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(GroupedListStyle())
            }
            .navigationBarTitle("Entries")
        }
    }
}

struct EntryView: View {
    @State var title = ""
    @State var bodyString = ""
    @State var images = [EntryImage]()
    @State var entryDate = Date()
    @State var pickerIsActive: Bool = false
    @State var isEditingContent: Bool = false

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }

    @Environment(\.managedObjectContext) var managedObjectContext

    private var entry: EntryPost?

    init() { }

    init(entry: EntryPost) {
        _title = State(initialValue: entry.title ?? "")
        _bodyString = State(initialValue: entry.body ?? "")
        _entryDate = State(initialValue: entry.entryDate ?? Date())
        _images = State(initialValue: Array(entry.images ?? []))

        self.entry = entry
    }

    var body: some View {
        VStack {
            List {
                Section(header: Text("Modify")) {
                    TextField("Title", text: $title)
                        .font(.headline)
                    NavigationLink(destination: ContentEntryView(bodyString: $bodyString)) {
                        Text(bodyString)
                    }
                    DatePicker(selection: $entryDate,
                               in: Date(timeIntervalSince1970: 0)...,
                               displayedComponents: .date) {
                                Text("Date is \(entryDate, formatter: dateFormatter)")
                    }
                    ForEach(images) { entryImage in
                        Image(uiImage: entryImage.uiimage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)

                    }
                    Button(action: {
                        self.pickerIsActive = true
                    }) {
                        Text("Import image")
                    }
                    .sheet(isPresented: $pickerIsActive) {
                        ImagePicker(imagePicked: { image in
                            if let image = image {
                                let entryImage = EntryImage(context: self.managedObjectContext)
                                entryImage.data = image.jpegData(compressionQuality: 90)
                                entryImage.imageDate = Date()
                                self.images.append(entryImage)
                            }
                        })
                    }
                }
                Section {
                    Button(action: {
                        let entry = EntryPost(context: self.managedObjectContext)
                        entry.title = self.title
                        entry.body = self.bodyString
                        entry.entryDate = self.entryDate
                        entry.images = Set(self.images)
                        try? self.managedObjectContext.save()
                    }) {
                        Text("Save")
                    }
                }

            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Edit")
        }
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
