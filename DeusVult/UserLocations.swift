//
//  UserLocations.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 15.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

class UserLocations: Object {
    dynamic var longitude = 0.0
    dynamic var latitude = 0.0
    dynamic var userID = ""
    var location : CLLocation {
        get {
            return CLLocation(latitude: latitude, longitude: longitude)
        }
    }
}
