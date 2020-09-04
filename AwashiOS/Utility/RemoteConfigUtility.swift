//
//  RemoteConfigUtility.swift
//  AwashiOS
//
//  Copyright © 2018 Awashapp. All rights reserved.
//

import FirebaseAnalytics
import Firebase

struct RemoteConfigKey {
    
    static let appStoreURL          = "app_store_url"
    static let apiBaseURL          = "api_base_url"
    
    
}

class RemoteConfigUtility {
    
    
    public static var sharedInstance = RemoteConfigUtility()
    var remoteConfig: RemoteConfig?
    
    private  init() {
        //private init for singleton class object
    }
    
    func setup() {
        
        remoteConfig = RemoteConfig.remoteConfig()
        let remoteConfigSettings = RemoteConfigSettings(developerModeEnabled: Utilities.isInDevelopmentMode())
        remoteConfig?.configSettings = remoteConfigSettings
        
        // Fetch default configuration from local plist
        
        if Utilities.isInDevelopmentMode() {
            remoteConfig?.setDefaults(fromPlist: "RemoteConfigDev")
        } else {
            remoteConfig?.setDefaults(fromPlist: "RemoteConfigProd")
        }
        
        
        // Cache expiration: 1 hour(3600 milliseconds)
        remoteConfig?.fetch(withExpirationDuration: TimeInterval(1)) { (status, error) -> Void in
            if (status == RemoteConfigFetchStatus.success) {
                print("Config fetched!")
                self.remoteConfig?.activateFetched()
            } else {
                print("Config not fetched")
                print("Error \(error!.localizedDescription)")
                
            }
        }
    }
    
    func getRemoteConfigValueForKey(key: String) -> RemoteConfigValue {
        return (remoteConfig?.configValue(forKey: key))!
    }
 
    
}
