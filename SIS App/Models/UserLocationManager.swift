//
//  UserLocationManager.swift
//  SIS App
//
//  Created by Wang Yunze on 12/11/20.
//

import CoreLocation
import Foundation
import NotificationCenter

class UserLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var userLocation: CLLocation?
    var previousUserLocation: CLLocation?

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
        locationManager.allowsBackgroundLocationUpdates = true
    }

    // MARK: Delegate Methods

    // User Location
    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            previousUserLocation = userLocation
            userLocation = location
        }

        if userLocation != nil, previousUserLocation != nil {
            let isInsideSchool = userLocation!.distance(from: Constants.schoolLocation) <= Constants.schoolRadius
            let previouslyInsideSchool = previousUserLocation!.distance(from: Constants.schoolLocation) <= Constants.schoolRadius

            if isInsideSchool { // Inside of school
                for block in DataProvider.getBlocks() {
                    let currentlyInBlock = isInsideBlock(location: userLocation!, block: block)
                    let previouslyInBlock = isInsideBlock(location: previousUserLocation!, block: block)
                    if currentlyInBlock, !previouslyInBlock {
                        // Entered a block!
                        print("📍 entered a block: \(block.name)")
                        NotificationCenter.default.post(name: .didEnterBlock, object: nil, userInfo: [Constants.notificationCenterBlockUserInfo: block])
                    } else if !currentlyInBlock, previouslyInBlock {
                        // Left a block!
                        print("📍 left a block: \(block.name)")
                        NotificationCenter.default.post(name: .didExitBlock, object: nil, userInfo: [Constants.notificationCenterBlockUserInfo: block])
                    }
                }
            }

            if isInsideSchool, !previouslyInsideSchool {
                print("📍 entered the school")
                NotificationCenter.default.post(name: .didEnterSchool, object: nil)
            } else if !isInsideSchool, previouslyInsideSchool {
                print("📍 exited the schoool ")
                NotificationCenter.default.post(name: .didExitSchool, object: nil)
            }
        } else {
            print("userlocation or previous user location is nil :(")
        }
    }

    // Error handling
    func locationManager(_: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier \(region?.identifier ?? "Unknown CLRegion") with error \(error)")
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }

    // MARK: Helper Methods

    private func isInsideBlock(location: CLLocation, block: Block) -> Bool {
        return location.distance(from: block.location.toCLLocation()) <= block.radius
    }
}
