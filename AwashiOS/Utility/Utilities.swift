//
//  Utilities.swift
//  AwashiOS
//

//  Copyright © 2017 Awashapp. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class Utilities {
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        
        return formatter
    }()
    
    static func showAlertMessage(_ title: String, message: String, actions: [UIAlertAction]) {
        
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        for action in actions {
            alertViewController.addAction(action)
        }
        UIApplication.shared.keyWindow?.rootViewController?.present(alertViewController, animated: true, completion: nil)
    }
    
    static func isInDevelopmentMode() -> Bool{
        let bundleDict = Bundle.main.infoDictionary
        let bundleIdentifier = bundleDict!["CFBundleIdentifier"] as! String
        
        if bundleIdentifier.lowercased().contains("dev") {
            return true
        }
        else{
            return false
        }
        
    }
    
    static func utcToLocal(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        formatter.timeZone = TimeZone.current
        
        let localDateString = formatter.string(from: date)
        
        return localDateString
    }
    
    static func utcToLocalDate(date: String?) -> Date {
        if let inputdate = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            let utcDate = formatter.date(from: inputdate)
            
            return utcDate!
        }
        
        return Date()
    }
    
    static func gradientByDay(day: String) -> [UIColor] {
        switch day {
        case "Monday":
            return [UIColor(hex: "FF5102").withAlphaComponent(0), UIColor(hex: "FF5102").withAlphaComponent(0.58), UIColor(hex: "FF5102").withAlphaComponent(1)]
        case "Tuesday":
            return [UIColor(hex: "FEAE00").withAlphaComponent(0), UIColor(hex: "FEAE00").withAlphaComponent(0.58), UIColor(hex: "FEAE00").withAlphaComponent(1)]
        case "Wednesday":
            return [UIColor(hex: "08C276").withAlphaComponent(0), UIColor(hex: "08C276").withAlphaComponent(0.58), UIColor(hex: "08C276").withAlphaComponent(1)]
        case "Thursday":
            return [UIColor(hex: "1FD2FA").withAlphaComponent(0), UIColor(hex: "1FD2FA").withAlphaComponent(0.58), UIColor(hex: "1FD2FA").withAlphaComponent(1)]
        case "Friday":
            return [UIColor(hex: "1C20BE").withAlphaComponent(0), UIColor(hex: "1C20BE").withAlphaComponent(0.58), UIColor(hex: "1C20BE").withAlphaComponent(1)]
        case "Saturday":
            return [UIColor(hex: "AF0894").withAlphaComponent(0), UIColor(hex: "AF0894").withAlphaComponent(0.58), UIColor(hex: "AF0894").withAlphaComponent(1)]
        case "Sunday":
            return [UIColor(hex: "B50032").withAlphaComponent(0), UIColor(hex: "B50032").withAlphaComponent(0.58), UIColor(hex: "B50032").withAlphaComponent(1)]
        default:
            return [UIColor.clear.withAlphaComponent(0)]
        }
    }
    
    static func gradientForImage(name: String) -> [UIColor] {
        switch name {
        case "intro":
            return [UIColor(hex: "5227C9").withAlphaComponent(0), UIColor(hex: "5227C9").withAlphaComponent(0.58), UIColor(hex: "5024c9").withAlphaComponent(1)]
        case "course":
            return gradientByDay(day: getDayOfWeek())
        case "morning":
            return [UIColor(hex: "FF5102").withAlphaComponent(0), UIColor(hex: "FF5102").withAlphaComponent(0.58), UIColor(hex: "FF5102").withAlphaComponent(1)]
        case "afternoon":
            return [UIColor(hex: "1A1FBB").withAlphaComponent(0), UIColor(hex: "1A1FBB").withAlphaComponent(0.58), UIColor(hex: "1A1FBB").withAlphaComponent(1)]
        case "evening":
            return [UIColor(hex: "35159C").withAlphaComponent(0), UIColor(hex: "35159C").withAlphaComponent(0.58), UIColor(hex: "35159C").withAlphaComponent(1)]
        default:
            return [UIColor.clear.withAlphaComponent(0)]
        }
    }
    
    static func getDayOfWeek() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat  = "EEEE"
        let dayInWeek = dateFormatter.string(from: date)//"Sunday"
        
        return dayInWeek
    }
}
