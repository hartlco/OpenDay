import SwiftUI
import LocationService

struct LocationSearchView: View {
    @EnvironmentObject var viewModel: LocationSearchViewModel
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var didSelectLocation: (LocationServiceLocation) -> Void

    var body: some View {
        List {
            TextField("Search - Enter City Name", text: $viewModel.searchText)
                .modifier(ClearButton(text: $viewModel.searchText))
            ForEach(viewModel.locations) { location in
                Text(self.viewModel.text(for: location)).onTapGesture {
                    self.didSelectLocation(location)
                    self.mode.wrappedValue.dismiss()
                }
            }
        }
        .navigationBarTitle("Search Location", displayMode: .inline)
    }
}

public struct ClearButton: ViewModifier {
    @Binding var text: String

    public init(text: Binding<String>) {
        self._text = text
    }

    public func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
            Image(systemName: "multiply.circle.fill")
                .foregroundColor(.secondary)
                .opacity(text == "" ? 0 : 1)
                .onTapGesture { self.text = "" }
        }
    }
}
