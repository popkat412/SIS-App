//
//  UserLocationManager.swift
//  SIS App
//
//  Created by Wang Yunze on 12/11/20.
//

import CoreLocation
import Foundation
import NotificationCenter
import WidgetKit

class UserLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocation? {
        didSet {
            FileUtility.saveDataToJsonFile(filename: Constants.userLocationFilename, data: Location(fromCLLocation: userLocation!))
            WidgetCenter.shared.reloadAllTimelines()
        }
        willSet {
            previousUserLocation = userLocation
        }
    }

    private(set) var previousUserLocation: CLLocation?

    let locationManager = CLLocationManager()

    private var isInsideSchool: Bool { userLocation!.distance(from: Constants.schoolLocation) <= Constants.schoolRadius }
    private var previouslyInsideSchool: Bool { previousUserLocation!.distance(from: Constants.schoolLocation) <= Constants.schoolRadius }

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
            userLocation = location
        }

        if userLocation != nil, previousUserLocation != nil {
            if isInsideSchool { // Inside of school
                for block in DataProvider.getBlocks() {
                    let currentlyInBlock = isCurrentlyInside(block: block)
                    let previouslyInBlock = isPreviouslyInside(block: block)
                    if currentlyInBlock, !previouslyInBlock {
                        // Entered a block!
                        print("📍 entered a block: \(block.name)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.geofenceDelayTime) {
                            if self.isCurrentlyInside(block: block) {
                                print("📍 still inside \(block.name) after \(Constants.geofenceDelayTime)s")
                                NotificationCenter.default.post(name: .didEnterBlock, object: nil, userInfo: [Constants.notificationCenterBlockUserInfo: block])
                            } else {
                                print("📍 no longer inside \(block.name) after \(Constants.geofenceDelayTime)")
                            }
                        }
                    } else if !currentlyInBlock, previouslyInBlock {
                        // Left a block!
                        print("📍 left a block: \(block.name)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.geofenceDelayTime) {
                            if !self.isCurrentlyInside(block: block) {
                                print("📍 still outside \(block.name) after \(Constants.geofenceDelayTime)s")
                                NotificationCenter.default.post(name: .didExitBlock, object: nil, userInfo: [Constants.notificationCenterBlockUserInfo: block])
                            } else {
                                print("📍 no longer inside \(block.name) after \(Constants.geofenceDelayTime)")
                            }
                        }
                    }
                }
            }

            if isInsideSchool, !previouslyInsideSchool {
                print("📍 entered the school")
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.geofenceDelayTime) {
                    print("📍 entered school, \(Constants.geofenceDelayTime) seconds later")
                    if self.isInsideSchool {
                        print("📍 still inside school after \(Constants.geofenceDelayTime)s")
                        NotificationCenter.default.post(name: .didEnterSchool, object: nil)
                    }
                }
            } else if !isInsideSchool, previouslyInsideSchool {
                print("📍 exited the schoool ")
                DispatchQueue.main.asyncAfter(deadline: .now() + Constants.geofenceDelayTime) {
                    print("📍 exited school, \(Constants.geofenceDelayTime) seconds later")
                    if self.isInsideSchool {
                        print("📍 still outside school after \(Constants.geofenceDelayTime)s")
                        NotificationCenter.default.post(name: .didExitSchool, object: nil)
                    }
                }
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

    private func isCurrentlyInside(block: Block) -> Bool {
        guard let userLocation = userLocation else { return false }
        return userLocation.distance(from: block.location.toCLLocation()) <= block.radius
    }

    private func isPreviouslyInside(block: Block) -> Bool {
        guard let previousUserLocation = previousUserLocation else { return false }
        return previousUserLocation.distance(from: block.location.toCLLocation()) <= block.radius
    }
}
