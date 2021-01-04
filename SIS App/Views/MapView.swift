//
//  MapView.swift
//  SIS App
//
//  Created by Wang Yunze on 17/10/20.
//

import CoreLocation
import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
    @EnvironmentObject var userLocationManager: UserLocationManager
    @Environment(\.colorScheme) var colorScheme: ColorScheme

    var shouldRemainFixedAtSchool: Bool = false
    var shouldShowTextLabels: Bool = true
    var pinsToShow: [Location] = []

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)

        // Delegate
        mapView.delegate = context.coordinator

        // Overlays for debugging geofences
        if Constants.shouldDrawDebugGeofences {
            for block in DataProvider.getBlocks() {
                print("adding overlay... \(block.name)")
                mapView.addOverlay(
                    MKCircle(
                        center: block.location.toCLLocation().coordinate,
                        radius: block.radius
                    )
                )
            }
            mapView.addOverlay(
                MKCircle(
                    center: Constants.schoolLocation.coordinate,
                    radius: Constants.schoolRadius
                )
            )
        }

        // Overlays for block outline
        let blockOutlines = FileUtility.getDataFromJsonAppbundleFile(filename: Constants.blockOutlineFilename, dataType: [BlockOutlineInfo].self)!

        for outline in blockOutlines {
            let boundary = outline.boundary.map {
                $0.toCLLocationCoordinate2D()
            }
            print("adding outline: \(outline.block), \(boundary)")
            mapView.addOverlay(
                MKPolygon(
                    coordinates: boundary,
                    count: outline.boundary.count
                )
            )
        }

        if shouldShowTextLabels {
            // Annotations for block names
            mapView.addAnnotations(
                DataProvider.getBlocks().map {
                    TextPointAnnotation(
                        coordinate: $0.location.toCLLocationCoordinate2D(),
                        text: $0.name
                    )
                }
            )
        }

        print("pins to show: \(pinsToShow)")
        mapView.addAnnotations(pinsToShow.map {
            let annotation = MKPointAnnotation()
            annotation.coordinate = $0.toCLLocationCoordinate2D()
            return annotation
        })

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context _: Context) {
        // Follow User Location
        if shouldRemainFixedAtSchool {
            mapView.showsUserLocation = false
            mapView.setRegion(
                MKCoordinateRegion(
                    center: Constants.schoolLocation.coordinate,
                    span: MKCoordinateSpan(
                        latitudeDelta: 0.002,
                        longitudeDelta: 0.002
                    )
                ),
                animated: true
            )
        } else {
            let coordinate = userLocationManager.userLocation?.coordinate ?? Constants.schoolLocation.coordinate
            let span = MKCoordinateSpan(
                latitudeDelta: 0.001,
                longitudeDelta: 0.001
            )
            let region = MKCoordinateRegion(
                center: coordinate,
                span: span
            )
            mapView.showsUserLocation = true
            mapView.setRegion(region, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(UserLocationManager())
    }
}

extension MapView {
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            print("overlay: \(overlay)")
            if overlay is MKCircle {
                let circle = MKCircleRenderer(overlay: overlay)
                circle.strokeColor = UIColor.red
                circle.fillColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.1)
                circle.lineWidth = 1
                return circle
            } else if overlay is MKPolygon {
                print("drawing outline")
                let polygonView = MKPolygonRenderer(overlay: overlay)
                polygonView.strokeColor = UIColor(named: Constants.overlayOutlineColorName)
                polygonView.lineWidth = 2
                return polygonView
            }

            return MKOverlayRenderer()
        }

        func mapView(_: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }

            if annotation is TextPointAnnotation {
                let annotationView = EmptyAnnotationView(
                    annotation: annotation, reuseIdentifier: "blocknameannotation"
                )
                let annotationLabel = UILabel(frame: CGRect(x: -100, y: 0, width: 200, height: 30))
                annotationLabel.numberOfLines = 3
                annotationLabel.textAlignment = .center
                annotationLabel.font = UIFont.systemFont(ofSize: 12)
                annotationLabel.text = annotation.title as? String
                annotationView.addSubview(annotationLabel)
                return annotationView
            }

            return MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin annotation")
        }
    }
}

extension MapView {
    private struct BlockOutlineInfo: Decodable {
        var block: String
        var boundary: [Location]
    }

    private class EmptyAnnotationView: MKAnnotationView {
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
        }

        override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        }
    }
}

private class TextPointAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var text: String

    init(coordinate: CLLocationCoordinate2D, text: String) {
        self.coordinate = coordinate
        self.text = text
    }
}
