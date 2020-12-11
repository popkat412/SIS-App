//
//  Location.swift
//  SIS App
//
//  Created by Wang Yunze on 7/11/20.
//

import CoreLocation
import Foundation

struct Location: Codable {
    var longitude: Double
    var latitude: Double

    func toCLLocation() -> CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }

    func toCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }

    init(fromCLLocation loc: CLLocation) {
        longitude = loc.coordinate.longitude
        latitude = loc.coordinate.latitude
    }
}
