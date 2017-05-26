//
//  Users.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 24.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import Foundation
import RealmSwift

class Users: Object {
    dynamic var name: String = ""
    dynamic var level: Int = 0
    dynamic var userId: String = ""
    dynamic var life: Int = 0
}
