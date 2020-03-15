import SwiftUI
import MapKit
import Models

final class LandmarkAnnotation: NSObject, MKAnnotation {
    let location: Location
    let coordinate: CLLocationCoordinate2D

    init(location: Location) {
        self.location = location
        self.coordinate = .init(latitude: location.latitude, longitude: location.longitude)
    }
}

#if os(iOS)

public struct MapView: UIViewRepresentable {
    @Binding var locations: [Location]

    var didSelect: ((Location) -> Void)?

    public init(locations: Binding<[Location]>,
                didSelect: ((Location) -> Void)? = nil) {
        self._locations = locations
        self.didSelect = didSelect
    }

    public func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.delegate = context.coordinator
        return map
    }

    public func updateUIView(_ uiView: MKMapView, context: Context) {
        updateAnnotations(from: uiView)
    }

    private func updateAnnotations(from mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
      let newAnnotations = locations.map { LandmarkAnnotation(location: $0) }
      mapView.addAnnotations(newAnnotations)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final public class Coordinator: NSObject, MKMapViewDelegate {
        var control: MapView

        init(_ control: MapView) {
            self.control = control
        }

        public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let annotation = view.annotation as? LandmarkAnnotation else { return }

            control.didSelect?(annotation.location)
        }
    }
}

#endif

#if os(macOS)

public struct MapView: NSViewRepresentable {
    @Binding var locations: [Location]

    public init(locations: Binding<[Location]>) {
        self._locations = locations
    }

    public func makeNSView(context: NSViewRepresentableContext<MapView>) -> MKMapView {
        return MKMapView()
    }

    public func updateNSView(_ nsView: MKMapView, context: NSViewRepresentableContext<MapView>) {
        updateAnnotations(from: nsView)
    }

    private func updateAnnotations(from mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
      let newAnnotations = locations.map { LandmarkAnnotation(location: $0) }
      mapView.addAnnotations(newAnnotations)
    }
}

#endif
