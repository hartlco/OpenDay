import SwiftUI
import KingfisherSwiftUI

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
                        VStack(alignment: .leading) {
                            Text(post.title ?? "")
                                .font(.headline)
                            Text(post.body ?? "")
                            Text(post.entryDate?.description ?? "")
                                .font(.footnote)
                        }
                    }
                }
            }
            .navigationBarTitle("Entries")
        }
    }
}

struct EntryView: View {
    @State var title = ""
    @State var bodyString = ""
    @State var images = [UIImage]()
    @Environment(\.managedObjectContext) var managedObjectContext

    private var entry: EntryPost?

    init() { }

    init(entry: EntryPost) {
        self.title = entry.title ?? ""
        self.bodyString = entry.body ?? ""

        self.entry = entry
    }

    var body: some View {
        VStack {
            List {
                Section {
                    TextField("Title", text: $title)
                        .font(.headline)
                    TextField("Content", text: $bodyString)
                        .font(.body)
                    Button(action: {

                    }) {
                        Text("Add Image")
                    }
                }
                Section {
                    Button(action: {
                        let entry = EntryPost(context: self.managedObjectContext)
                        entry.title = self.title
                        entry.body = self.bodyString
                        entry.entryDate = Date()
                        try? self.managedObjectContext.save()
                    }) {
                        Text("Save")
                    }
                }
            }.listStyle(GroupedListStyle())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
