import SwiftUI
import MapKit
import Models

final class LandmarkAnnotation: NSObject, MKAnnotation {
    let title: String?
    let coordinate: CLLocationCoordinate2D

    init(location: Location) {
        self.title = location.city ?? ""
        self.coordinate = .init(latitude: location.latitude, longitude: location.longitude)
    }
}

#if os(iOS)

public struct MapView: UIViewRepresentable {
    @Binding var locations: [Location]

    public init(locations: Binding<[Location]>) {
        self._locations = locations
    }

    public func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }

    public func updateUIView(_ uiView: MKMapView, context: Context) {
        updateAnnotations(from: uiView)
    }

    private func updateAnnotations(from mapView: MKMapView) {
        mapView.removeAnnotations(mapView.annotations)
      let newAnnotations = locations.map { LandmarkAnnotation(location: $0) }
      mapView.addAnnotations(newAnnotations)
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
