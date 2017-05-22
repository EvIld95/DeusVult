//
//  MulticolorPolylineSegment.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 20.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import Foundation


import UIKit
import MapKit
import CoreLocation

class MulticolorPolylineSegment: MKPolyline {
    var color: UIColor?
    
    private class func allSpeeds(forLocations locations: [LocationRM]) ->
        (speeds: [Double], minSpeed: Double, maxSpeed: Double) {
            
            let speeds = locations.map { (location) -> Double in
                return location.speed
            }
            
            let minSpeed = speeds.min()
            let maxSpeed = speeds.max()
            
            return (speeds, minSpeed!, maxSpeed!)
    }
    
    class func colorSegments(forLocations locations: [LocationRM]) -> [MulticolorPolylineSegment] {
        var colorSegments = [MulticolorPolylineSegment]()
        
        let (speeds, minSpeed, maxSpeed) = allSpeeds(forLocations: locations)
        //let meanSpeed = (minSpeed + maxSpeed)/2
        
        for i in 1..<locations.count {
            let l1 = locations[i-1]
            let l2 = locations[i]
            
            var coords = [CLLocationCoordinate2D]()
            
            coords.append(CLLocationCoordinate2D(latitude: l1.latitude, longitude: l1.longitude))
            coords.append(CLLocationCoordinate2D(latitude: l2.latitude, longitude: l2.longitude))
            
            let speed = speeds[i-1]
            
        
            let ratio = (speed - minSpeed) / (maxSpeed - minSpeed)//(speed - minSpeed) / (meanSpeed - minSpeed)
            
            let color = UIColor(hue: CGFloat(ratio * 120) / 360, saturation: 1.0, brightness: 1.0, alpha: 1.0)

            
            let segment = MulticolorPolylineSegment(coordinates: &coords, count: coords.count)
            segment.color = color
            colorSegments.append(segment)
        }
        
        return colorSegments
    }
}
