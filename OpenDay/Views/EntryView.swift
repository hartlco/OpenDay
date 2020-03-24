import SwiftUI
import OpenKit
import TextView

struct EntryView: View {
    @EnvironmentObject var store: EntryStore

    @State var pickerIsActive: Bool = false
    @State var isEditingContent: Bool = false
    @State var showDateLocationPopup = false
    @State var bodyTextHeight: CGFloat = 40

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
                    ExpandingTextView(placeholder: "Body",
                                      text: self.$store.bodyString,
                                      minHeight: self.bodyTextHeight,
                                      calculatedHeight: self.$bodyTextHeight)
                        .frame(minHeight: self.bodyTextHeight, maxHeight: self.bodyTextHeight)
                    ForEach(self.store.images) { entryImage in
                        Image(okImageData: entryImage.data!)
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fill)
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
                Section(header: Text("Date")) {
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
                store.currentWeather.map { (weather: EntryWeather) in
                    Section(header: Text("Weather")) {
                        Text(weather.weatherIconString ?? "")
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarItems(trailing: Button(action: {
                self.pickerIsActive = true
            }, label: {
                Image(systemName: "photo")
            }))
            .navigationBarTitle("Edit", displayMode: .inline)
            .onAppear {
                self.store.onAppear()
            }
            .onDisappear {
                self.store.save()
            }
        }
        .keyboardObserving()
    }
}
