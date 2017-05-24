//
//  Level.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 24.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import Foundation


class Level {
    class func levelForPoints(points: Int) -> Int {
        return (points / 500) + 1
    }
}
