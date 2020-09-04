//
//  UserDefaultsUtil.swift
//  AwashiOS
//
//
//  Copyright © 2018 Awashapp. All rights reserved.
//

import Foundation

class UserDefaultsUtil{
    
    class func store(value:Any?, forKey:String){
        UserDefaults.standard.set(value, forKey: forKey)
        UserDefaults.standard.synchronize()
    }
    
    class func value(forKey:String) -> Any?{
        return UserDefaults.standard.value(forKey: forKey)
    }
    
    class func remove(forKey key:String){
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    
    //MARK:- Feedback changes
    
    class func didshowFeedBackAlertRecently() -> Bool {
        return (self.value(forKey: Constants.UserDefaultsKeys.didShowRatingDialogueRecently) as? Bool) ?? false
    }
    
    class func feedbackdidSubmitRating() -> Bool {
        return (self.value(forKey: Constants.UserDefaultsKeys.didSubmitRating) as? Bool) ?? false
    }
    
    class func storeDidshowFeedBackAlertRecently(bool: Bool) {
        self.store(value: bool , forKey: Constants.UserDefaultsKeys.didShowRatingDialogueRecently)
    }
    
    class func feedbackdidSubmitRating(bool: Bool)  {
        self.store(value: bool , forKey: Constants.UserDefaultsKeys.didSubmitRating)
    }
    
    class func storeFeedBackCount(count: Int, key: String) {
        self.store(value: count, forKey: key)
    }
    
    class func feedBackCount(key: String) -> Int {
        return (self.value(forKey: key) as? Int) ?? 0
    }
    
    class func storeAccessCode(code: String) {
        self.store(value: code, forKey: Constants.UserDefaultsKeys.accessCode)
    }
    
    class func accessCode() -> String {
        return (self.value(forKey: Constants.UserDefaultsKeys.accessCode) as? String) ?? ""
    }
    
    //MARK: Clear user data
    class func clearUserData(){
        //UserDefaults.standard.removeObject(forKey: K.UserDefaultKey.featureAlertSettings)
        UserDefaults.standard.setValue(false, forKey: Constants.UserDefaultsKeys.didSubmitRating)
        UserDefaults.standard.setValue(false, forKey: Constants.UserDefaultsKeys.didShowRatingDialogueRecently)
        UserDefaults.standard.setValue(0, forKey: Constants.UserDefaultsKeys.firstGoalCount)
        UserDefaults.standard.setValue(0, forKey: Constants.UserDefaultsKeys.meditationCompleteCount)
        UserDefaults.standard.setValue(0, forKey: Constants.UserDefaultsKeys.encourageCount)
        UserDefaults.standard.synchronize()
        
    }
    
    //Will be used for migration
    class func removeUserData(){
        if let userDefaultKeys = self.getAccountSpecificDataKeys(){
            for key in userDefaultKeys{
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        UserDefaults.standard.synchronize()
    }
    
    //Migration: Get the keys those are specific to account but stored in app level
    class func getAccountSpecificDataKeys() -> [String]?{
        
        return [Constants.UserDefaultsKeys.meditationCompleteCount
        ]
    }
    
}
