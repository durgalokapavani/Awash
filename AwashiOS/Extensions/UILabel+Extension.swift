//
//  UILabel+Extension.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 2/20/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import UIKit

@IBDesignable
@objcMembers
class RoundUILabel: UILabel {
    
    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 2.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    
}
