import SwiftUI

struct ContentView: View {
    @FetchRequest(fetchRequest: EntryPost.allPostsFetchRequest()) var posts: FetchedResults<EntryPost>

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: AddView(),
                               label: {
                                Text("Add")
                })
                List(posts) { post in
                    Text(post.title ?? "")
                }
            }
            .navigationBarTitle("Entries")
        }
    }
}

struct AddView: View {
    @State var title = ""
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        VStack {
            TextField("Title", text: $title)
            Button(action: {
                let entry = EntryPost(context: self.managedObjectContext)
                entry.title = self.title
                entry.entryDate = Date()
                try? self.managedObjectContext.save()
            }) {
                Text("Save")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
