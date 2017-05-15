//
//  Run.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 14.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

class Run : Object {
    dynamic var date: Date!
    dynamic var time = 0
    dynamic var distance = 0.0
    dynamic var averageSpeed = 0.0
    dynamic var maxSpeed = 0.0
    let locations = List<LocationRM>()
}
