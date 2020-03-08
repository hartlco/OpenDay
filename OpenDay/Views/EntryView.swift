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
