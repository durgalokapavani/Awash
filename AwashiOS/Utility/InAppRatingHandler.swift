//
//  InAppRatingHandler.swift
//  AwashiOS
//  Copyright © 2018 Awashapp. All rights reserved.
//

import Foundation
import StoreKit

enum InAppRatingRule {
    
    case meditationComplete
    case firstGoal
    case encourage
    
}

class InAppRatingHandler {
    
    static let shared = InAppRatingHandler()
    
    var userdefaultKeyScenario: String?
    var scenarioLimit:  Int = 1
    var scenarioCount:  Int?
    
    func showRatingForRule(rule: InAppRatingRule) {
        
        switch rule {
        case .meditationComplete:
            userdefaultKeyScenario = Constants.UserDefaultsKeys.meditationCompleteCount
            scenarioLimit = 3
            break
        case .firstGoal:
            userdefaultKeyScenario = Constants.UserDefaultsKeys.firstGoalCount
            scenarioLimit = 1
            break
        case .encourage:
            userdefaultKeyScenario = Constants.UserDefaultsKeys.encourageCount
            scenarioLimit = 1
            break
        }
        
        scenarioCount = UserDefaultsUtil.feedBackCount(key: userdefaultKeyScenario!) + 1
        UserDefaultsUtil.storeFeedBackCount(count: scenarioCount!, key: userdefaultKeyScenario!)
        
        if scenarioCount == scenarioLimit {
            UserDefaultsUtil.storeFeedBackCount(count: 0, key: userdefaultKeyScenario!)
            DispatchQueue.main.async {
                self.showRatingGate()
            }
            
            
        }
        
    }
    
    @objc private func updateTime() {
        UserDefaultsUtil.storeDidshowFeedBackAlertRecently(bool: false)
    }
    
    func showRatingGate() {
        
        if !UserDefaultsUtil.didshowFeedBackAlertRecently() && !UserDefaultsUtil.feedbackdidSubmitRating() {
            
            UserDefaultsUtil.storeDidshowFeedBackAlertRecently(bool: true)
            Timer.scheduledTimer(timeInterval: 2592000,
                                 target: self,
                                 selector: #selector(self.updateTime),
                                 userInfo: nil,
                                 repeats: true)
        
            
            let alertViewController = UIAlertController(title: "Awash Experience", message: "Have you been enjoying your Awash experience?", preferredStyle: UIAlertControllerStyle.alert)
            
            let alertActionNo = UIAlertAction(title: "Not Really", style: UIAlertActionStyle.default) { (action) -> Void in
                AnalyticsHandler.shared.trackEvent(of: .event, name: "FEEDBACK_ENJOYING_NOT_REALLY", additionalInfo: [:])
                
            }
            let alertActionYes = UIAlertAction(title: "Yes", style: UIAlertActionStyle.default) { (action) -> Void in
                AnalyticsHandler.shared.trackEvent(of: .event, name: "FEEDBACK_ENJOYING_YES", additionalInfo: [:])
                self.requestReview()
            }
            alertViewController.addAction(alertActionNo)
            alertViewController.addAction(alertActionYes)
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alertViewController, animated: true, completion: nil)
        }
        
    }
    
    func requestReview() {
        
        UserDefaultsUtil.feedbackdidSubmitRating(bool: true)
        
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            
            let alertActionNo = UIAlertAction(title: "Not Now", style: UIAlertActionStyle.default) { (action) -> Void in
            }
            let alertActionYes = UIAlertAction(title: "Ok Sure", style: UIAlertActionStyle.default) { (action) -> Void in
                
                // Fallback on earlier versions
                if let appStoreURL = RemoteConfigUtility.sharedInstance.getRemoteConfigValueForKey(key: RemoteConfigKey.appStoreURL).stringValue, let myAppURL = URL(string: appStoreURL) {
                    UIApplication.shared.open(myAppURL, options: [:],
                                              completionHandler: nil)
                }
                
            }
            
            showAlertMessage("How about a rating on App Store?", actions: [alertActionNo, alertActionYes])
            
        }
    }
    
    
    func showAlertMessage(_ message: String, actions: [UIAlertAction]) {
        
        let messageString = NSAttributedString(string: message, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15)])
        
        let alertViewController = UIAlertController(title: nil, message: message , preferredStyle: UIAlertControllerStyle.alert)
        alertViewController.setValue(messageString, forKey: "attributedMessage")
        for action in actions {
            alertViewController.addAction(action)
        }
        
        UIApplication.shared.keyWindow?.rootViewController?.present(alertViewController, animated: true, completion: nil)
    }
    
}
