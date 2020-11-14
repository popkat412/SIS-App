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
    var previousUserLocation: CLLocation?
    
    let locationManager = CLLocationManager()
    
    let schoolLocation = CLLocation(latitude: 1.347014, longitude: 103.845148)
    let schoolRadius = 222.94
    
    override init() {
        super.init()
        
        // Delegate
        locationManager.delegate = self
        
        // User location
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
    }
    
    // MARK: Delegate Methods
    
    // User Location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("did update locations")
        if let location = locations.last {
            previousUserLocation = userLocation
            userLocation = location
        }
        
        if userLocation != nil && previousUserLocation != nil {
            print("user locations are not nil :)")
            if userLocation!.distance(from: schoolLocation) <= schoolRadius { // Inside of school
                for block in DataProvider.getBlocks() {
                    let currentlyInBlock = isInsideBlock(location: userLocation!, block: block)
                    let previouslyInBlock = isInsideBlock(location: previousUserLocation!, block: block)
                    if currentlyInBlock && !previouslyInBlock {
                        // Entered a block!
                        print("📍 entered a block: \(block.name)")
                        NotificationCenter.default.post(name: .didEnterBlock, object: nil, userInfo: ["block": block])
                    } else if !currentlyInBlock && previouslyInBlock {
                        // Left a block!
                        print("📍 left a block: \(block.name)")
                        NotificationCenter.default.post(name: .didExitBlock, object: nil, userInfo: ["block": block])
                    }
                }
            }
        } else {
            print("userlocation or previous user location is nil :(")
        }
    }
    
    // Error handling
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier \(region?.identifier ?? "Unknown CLRegion") with error \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    // MARK: Helper Methods
    private func isInsideBlock(location: CLLocation, block: Block) -> Bool {
        return location.distance(from: block.location.toCLLocation()) <= block.radius
    }
}
