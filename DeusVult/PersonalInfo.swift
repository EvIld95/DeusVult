//
//  PersonalInfo.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 15.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import Foundation
import RealmSwift

class PersonalInfo: Object {
    dynamic var name: String = ""
    dynamic var weight: Float = 0.0
    dynamic var height: Float = 0.0
}
