//
//  Helpers.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 14.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import Foundation

func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}

func getTimeCorrectFormat(hours: Int, minutes: Int, sec: Int) -> String {
    var displayTimeText = (hours > 0) ? "\(hours) h " : ""
    displayTimeText += (minutes > 0) ? "\(minutes) min " : ""
    displayTimeText += "\(sec) sec"
    return displayTimeText
}

func calculateBurnedCalories(avgSpeed: Double, seconds: Int, weight: Double) -> Double{
    enum METRatioActivity: Double {
        case lessThan1kmPerHour = 1
        case to2kmPerHour = 2
        case to3kmPerHour = 3
        case to4kmPerHour = 4
        case to5kmPerHour = 5
        case to6kmPerHour = 6
        case to7kmPerHour = 7
        case to8kmPerHour = 8
        case to9kmPerHour = 9
        case to10kmPerHour = 10
        case to11kmPerHour = 11
        case to12kmPerHour = 12
        case to13kmPerHour = 13
        case to14kmPerHour = 14
        case to15kmPerHour = 15
        case more15kmPerHour = 16
        
        func getMetRatio() -> Double {
            switch self {
            case .lessThan1kmPerHour:
                return 0.1
            case .to2kmPerHour:
                return 1.0
            case .to3kmPerHour:
                return 2.0
            case .to4kmPerHour:
                return 3.0
            case .to5kmPerHour:
                return 3.5
            case .to6kmPerHour:
                return 4.0
            case .to7kmPerHour:
                return 5.0
            case .to8kmPerHour:
                return 6.5
            case .to9kmPerHour:
                return 8.0
            case .to10kmPerHour:
                return 10
            case .to11kmPerHour:
                return 11
            case .to12kmPerHour:
                return 12.5
            case .to13kmPerHour:
                return 13.5
            case .to14kmPerHour:
                return 14
            case .to15kmPerHour:
                return 15
            case .more15kmPerHour:
                return 16
            }
        }
    }
    
    var metRatioActivity : METRatioActivity!
    if(avgSpeed > 15.0) {
        metRatioActivity = METRatioActivity(rawValue: 16)!
    } else {
        metRatioActivity = METRatioActivity(rawValue: floor(avgSpeed) + 1)!
    }
    let ratio = metRatioActivity.getMetRatio()
    let minutes = seconds / 60
    let calories = ratio * Double(minutes) * weight * 3.5 / 200.0
    return calories
}
