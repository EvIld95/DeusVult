//
//  MuslimPosition.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 22.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class MuslimPosition: Object {
    dynamic var longitude = 0.0
    dynamic var latitude = 0.0
    dynamic var name = ""
    dynamic var strength = 0
    var location : CLLocation {
        get {
            return CLLocation(latitude: latitude, longitude: longitude)
        }
    }
}
