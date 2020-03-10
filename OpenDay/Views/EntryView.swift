import SwiftUI

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
                                Text("Date")
                    }
                    DatePicker(selection: self.$store.entryDate,
                               in: Date(timeIntervalSince1970: 0)...,
                               displayedComponents: .hourAndMinute) {
                                Text("Time")
                    }
                    ForEach(self.store.images) { entryImage in
                        Image(uiImage: entryImage.uiimage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .contextMenu {
                                Button(action: {
                                    self.store.delete(image: entryImage)
                                }, label: {
                                    Text("Delete")
                                    Image(systemName: "trash")
                                })
                        }

                    }
                }
                Section(header: Text("Location")) {
                    store.locationText.map {
                        Text($0)
                    }
                    Button(action: {
                        self.store.updateLocation()
                    }, label: {
                        Text("Current Location")
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
                    NavigationLink(destination: LocationSearchView { location in
                        self.store.currentLocation = location
                    }.environmentObject(store.locationSearchViewModel)) {
                                    Text("Search Location")
                    }.buttonStyle(DefaultButtonStyle())
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarItems(trailing: Button(action: {
                self.pickerIsActive = true
            }, label: {
                Image(systemName: "photo")
            }))
            .navigationBarTitle("Edit")
            .onDisappear {
                self.store.save()
            }
        }
        .keyboardObserving()
    }
}
