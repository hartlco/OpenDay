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

    private let userInteractionEnabled: Bool

    var didSelect: ((Location) -> Void)?

    public init(locations: Binding<[Location]>,
                userInteractionEnabled: Bool = true,
                didSelect: ((Location) -> Void)? = nil) {
        self._locations = locations
        self.didSelect = didSelect
        self.userInteractionEnabled = userInteractionEnabled
    }

    public func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()

        if userInteractionEnabled == false {
            map.isZoomEnabled = false
            map.isScrollEnabled = false
            map.isUserInteractionEnabled = false
        }

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

        if newAnnotations.count == 1, let first = newAnnotations.first {
            let span = mapView.region.span
            let center = CLLocationCoordinate2D(latitude: first.location.latitude,
                                                longitude: first.location.longitude)
            let region = MKCoordinateRegion(center: center, latitudinalMeters: 50000, longitudinalMeters: 50000)
            mapView.setRegion(region, animated: true)
        }
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

    private let userInteractionEnabled: Bool

    public init(locations: Binding<[Location]>,
                userInteractionEnabled: Bool = true) {
        self._locations = locations
        self.userInteractionEnabled = userInteractionEnabled
    }

    public func makeNSView(context: NSViewRepresentableContext<MapView>) -> MKMapView {
        let map = MKMapView()
        if userInteractionEnabled == false {
            map.isZoomEnabled = false
            map.isScrollEnabled = false
        }

        return map
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
