//
//  LocationRM.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 14.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

class LocationRM: Object {
    dynamic var longitude = 0.0
    dynamic var latitude = 0.0
    dynamic var altitude = 0.0
    dynamic var speed = 0.0

    var location : CLLocation {
        get {
            return CLLocation(latitude: latitude, longitude: longitude)
        }
    }
}
