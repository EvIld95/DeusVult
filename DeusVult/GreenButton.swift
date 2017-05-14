//
//  GreenButton.swift
//  DeusVult
//
//  Created by Paweł Szudrowicz on 14.05.2017.
//  Copyright © 2017 Paweł Szudrowicz. All rights reserved.
//

import UIKit

@IBDesignable
class GreenButton: UIButton {
    @IBInspectable var loginButtonColor: UIColor!  {
        didSet {
            self.layer.backgroundColor = loginButtonColor.cgColor
        }
    }
    
    @IBInspectable var borderButtonColor: UIColor! {
        didSet {
            self.layer.borderColor = borderButtonColor.cgColor
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.layer.backgroundColor =  UIColor.deusVultLightGreen.cgColor
        self.layer.borderWidth = 3
        self.layer.borderColor = UIColor.deusVultGreen.cgColor
        self.layer.cornerRadius = self.frame.height / 2
    }
    
}
