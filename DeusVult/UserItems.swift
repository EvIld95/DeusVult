//
//  UserItems.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 24.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import Foundation
import RealmSwift


enum ItemType: Int {
    case gold
    case sword
}

class UserItems: Object {
    dynamic var itemType: Int = 0
    dynamic var points: Int = 0
    dynamic var money: Int = 0
}
