//
//  UserLocationManager.swift
//  SIS App
//
//  Created by Wang Yunze on 12/11/20.
//

import Foundation
import CoreLocation
import NotificationCenter

class UserLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var userLocation: CLLocation?
    
    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        // Delegate
        locationManager.delegate = self
        
        // User location
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        
        // Geofencing
    }
    
    // MARK: Delegate Methods
    
    // User Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("did update locations")
        if let location = locations.last {
            userLocation = location
        }
    }
    
    // Geofencing
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("📍 did enter region! \(region)")
        NotificationCenter.default.post(name: .didEnterGeofence, object: nil, userInfo: ["region": region])
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("📍 did exit region! \(region)")
        NotificationCenter.default.post(name: .didExitGeofence, object: nil, userInfo: ["region": region])
    }
    
    // Error handling
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier \(region?.identifier ?? "Unknown CLRegion") with error \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    // MARK: Helper Methods
    private func makeRegion(with block: Block) -> CLCircularRegion {
        return CLCircularRegion(
            center: block.location.toCLLocation().coordinate,
            radius: block.radius,
            identifier: block.name
        )
    }
    
    private func startMonitoring(for block: Block) {
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            // TODO: Show some sort of alert to user
            print("Geofences not avaliable on this device")
            return
        }
        
        if locationManager.authorizationStatus != .authorizedAlways {
            // TODO: Show some sort of alert to user
            print("Geofences will only work if you grant this app permission to always access your location")
            return
        }
        
        let fence = makeRegion(with: block)
        locationManager.startMonitoring(for: fence)
    }
}
