import SwiftUI
import OpenKit
import TextView
import Models
import Kingfisher
import KingfisherSwiftUI

struct EntryView: SwiftUI.View {
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

    var body: some SwiftUI.View {
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
                    ForEach(self.store.images) { (entryImage: Models.ImageResource) in
                        self.image(for: entryImage)
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fill)
                            .contextMenu {
                                Button(action: {
//                                    self.store.delete(image: entryImage)
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
//                        self.store.currentLocation = location
                    }.environmentObject(store.locationSearchViewModel)) {
                                    Text("Search Location")
                    }.buttonStyle(DefaultButtonStyle())
                }
                store.currentWeather.map { (weather: Models.Weather) in
                    Section(header: Text("Weather")) {
                        Text(weather.weatherSymbol?.rawValue ?? "")
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

    private func image(for resource: Models.ImageResource) -> KFImage {
        switch resource {
        case .local(let data, _):
            return KFImage(source: .provider(AsyncRawImageDataProvider(data: data)))
        case .remote(let url):
            return KFImage(url)
        }
    }
}

/// Represents an image data provider for a raw data object.
struct AsyncRawImageDataProvider: ImageDataProvider {
    let data: Data

    init(data: Data) {
        self.cacheKey = String(data.hashValue)
        self.data = data
    }
    var cacheKey: String

    func data(handler: @escaping (Result<Data, Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            handler(.success(self.data))
        }
    }
}
