//
//  AnalyticsHandler.swift
//  AwashiOS
//

//  Copyright © 2017 Awashapp. All rights reserved.
//

import Foundation
import Firebase
import Crashlytics

enum AnalyticsType{
    case error
    case warning
    case view
    case event
}


class AnalyticsHandler{
    
    public static var shared = AnalyticsHandler()
    var enableAnaytics:Bool = true
    
    private  init() {
        self.setUserId()
        
    }
    
    
    private func logEvent(withName: String, logLevel: AnalyticsType, additionalData: [String:String]) {
        if self.enableAnaytics{
            Analytics.logEvent(withName, parameters: additionalData)
        
        }
    }
    
    //MARK: Analytics methods
    func trackEvent(of type:AnalyticsType, name:String){
        self.trackEvent(of: type, name: name, additionalInfo: [:])
        
    }
    
    func trackEvent(of type:AnalyticsType, name:String, additionalInfo:[String:String]){
        
        self.logEvent(withName: name, logLevel: type, additionalData: additionalInfo)
    }
    
    func setUserId() {
        if self.enableAnaytics {
            AwashUser.shared.getUserEmail { userId in
                Analytics.setUserProperty(userId, forName: "userId")
                Analytics.setUserID(userId)
                Crashlytics.sharedInstance().setUserIdentifier(userId)
            }
        }
    }
    
    
    
    func resetAnalyticsData(){
        Analytics.setUserProperty("", forName: "userId")
        Analytics.setUserID("")
        Crashlytics.sharedInstance().setUserIdentifier("")
    }
    
    
}
