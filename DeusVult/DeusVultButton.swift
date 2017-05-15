//
//  GreenButton.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 14.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit

@IBDesignable
class DeusVultButton: UIButton {
    @IBInspectable var backgroundButtonColor: UIColor! = UIColor.deusVultLightGreen {
        didSet {
            self.layer.backgroundColor = backgroundButtonColor.cgColor
        }
    }
    
    @IBInspectable var borderButtonColor: UIColor! = UIColor.deusVultGreen {
        didSet {
            self.layer.borderColor = borderButtonColor.cgColor
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.backgroundColor =  backgroundButtonColor.cgColor
        self.layer.borderWidth = 3
        self.layer.borderColor = borderButtonColor.cgColor
        self.layer.cornerRadius = self.frame.height / 2
    }
    
}
