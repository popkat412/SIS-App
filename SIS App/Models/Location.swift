//
//  Location.swift
//  SIS App
//
//  Created by Wang Yunze on 7/11/20.
//

import Foundation
import CoreLocation

struct Location: Codable {
    var longitude: Double
    var latitude: Double
    
    func toCLLocation() -> CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}
