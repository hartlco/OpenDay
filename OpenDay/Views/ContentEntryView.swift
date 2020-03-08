import SwiftUI
import TextView

struct ContentEntryView: View {
    @Binding var bodyString: String

    var body: some View {
        TextView(text: $bodyString)
        .navigationBarTitle("Edit body")
        .keyboardObserving()
    }
}
