//
//  SpacingLabel+Extension.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 3/15/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import UIKit

@IBDesignable
@objcMembers
class SpacingLabel : UILabel {
    @IBInspectable var characterSpacing:CGFloat = 1 {
        didSet {
            let attributedString = NSMutableAttributedString(string: self.text!)
            attributedString.addAttribute(NSAttributedStringKey.kern, value: self.characterSpacing, range: NSRange(location: 0, length: attributedString.length))
            self.attributedText = attributedString
        }
        
    }
}
