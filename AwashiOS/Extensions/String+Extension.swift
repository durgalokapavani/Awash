//
//  String+Extension.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 3/21/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
