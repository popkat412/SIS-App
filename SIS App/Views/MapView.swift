//
//  MapView.swift
//  SIS App
//
//  Created by Wang Yunze on 17/10/20.
//

import SwiftUI
import CoreLocation
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var userLocation: CLLocation

    func makeUIView(context: Context) -> MKMapView {

        return MKMapView(frame: .zero)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 1.346236, 103.844112
        
//        let coordinate = CLLocationCoordinate2D(
//            latitude: 1.346232,
//            longitude: 103.844188
//        )
        let coordinate = userLocation.coordinate
        
        let span = MKCoordinateSpan(
            latitudeDelta: 0.001,
            longitudeDelta: 0.001
        )
        
        let region = MKCoordinateRegion(
            center: coordinate,
            span: span
        )
        
        uiView.showsUserLocation = true
        uiView.setRegion(region, animated: true)
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(userLocation: $userLocation)
    }
}

struct MapView_Previews: PreviewProvider {
    @State static var testLocation = CLLocation()
    
    static var previews: some View {
        MapView(userLocation: $testLocation)
    }
}

class MapViewCoordinator: NSObject, CLLocationManagerDelegate {
    @Binding var userLocation: CLLocation
    
    let locationManager = CLLocationManager()
    
    init(userLocation: Binding<CLLocation>) {
        self._userLocation = userLocation
        super.init()
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("didUpdateLocations")
        if let currLocation = locations.last {
            userLocation = currLocation
        }
    }
}
