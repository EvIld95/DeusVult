//
//  Constants.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 14.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    public class var deusVultLightGreen: UIColor! {
        get {
            return UIColor(red: 143.0/255.0, green: 250.0/255.0, blue: 133.0/255.0, alpha: 1.0)
        }
    }
    
    public class var deusVultGreen: UIColor! {
        get {
            return UIColor(red: 67.0/255.0, green: 217.0/255.0, blue: 154.0/255.0, alpha: 1.0)
        }
    }
}



extension UIColor {
    
    func rgb() -> (red:Int, green:Int, blue:Int, alpha:Int)? {
        var fRed : CGFloat = 0.0
        var fGreen : CGFloat = 0.0
        var fBlue : CGFloat = 0.0
        var fAlpha: CGFloat = 0.0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            
            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            return nil
        }
    }
}
