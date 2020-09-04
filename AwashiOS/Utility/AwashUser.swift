//
//  AwashUser.swift
//  AwashiOS
//

//  Copyright © 2017 Awashapp. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider
import AWSUserPoolsSignIn

class AwashUser {
    static let shared = AwashUser()
    fileprivate var pool:AWSCognitoIdentityUserPool?
    
    private init() {}
    
    func user() -> AWSCognitoIdentityUser? {
        pool = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool()
        return pool?.currentUser()
    }
    
    func isLoggedIn() -> Bool {
        let isUserLoggedIn = pool?.currentUser()?.isSignedIn ?? false
        return isUserLoggedIn || AWSSignInManager.sharedInstance().isLoggedIn
    }
    
    func getUserId(completion: @escaping (String) -> Void) {
        if isLoggedIn() {
            
            if let currentUser = self.user() {
                currentUser.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
                    if let response = task.result, let attributes = response.userAttributes  {
                        
                        attributes.forEach({ (userAttribute) in
                            if userAttribute.name!.elementsEqual("sub") {
                                completion(userAttribute.value!)
                            }
                        })
                        
                    }
                    return nil
                }
            }
            
        } else {
            completion(AWSIdentityManager.default().identityId!)
        }
        
    }
    
    func getUserEmail(completion: @escaping (String) -> Void) {
        if isLoggedIn() {
            
            if let currentUser = self.user() {
                currentUser.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
                    if let response = task.result, let attributes = response.userAttributes  {
                        
                        attributes.forEach({ (userAttribute) in
                            if userAttribute.name!.elementsEqual("email") {
                                completion(userAttribute.value!)
                            }
                        })
                        
                    }
                    return nil
                }
            }
            
        } else {
            if let identityId = AWSIdentityManager.default().identityId {
                completion(String(identityId.prefix(23)))
            }
            
        }
        
    }
    
    func isUserAllowedAccess(meditation: Meditation, completion: @escaping (Bool) -> Void) {
        completion(true)
        /*
        if meditation.type.elementsEqual("free") {
            completion(true)
            return
        }
        self.isSubscribed() { subscribed in
            if subscribed {
                completion(true)
            } else {
                completion(false)
            }
        }
        */
    }
    
    func isSubscribed(completion: @escaping (Bool) -> Void){
        if !isLoggedIn() {completion(false)}
        
        
        completion(IAPHandler.shared.isSubscriptionActive())
 
    }
    
    func logout(completion: @escaping ((Bool) -> Void)) {
        let identityManager = AWSIdentityManager.default()
        print("auth state BEFORE logout: ", identityManager.authState().rawValue)
        print("user id BEFORE logout: ", identityManager.identityId ?? "")
        print("user name BEFORE logout: ", AwashUser.shared.user()?.username ?? "NO USERNAME")
        
        AnalyticsHandler.shared.trackEvent(of: .event, name: "logout")
        AnalyticsHandler.shared.resetAnalyticsData()
        
        if (isLoggedIn()) {
            AWSSignInManager.sharedInstance().logout(completionHandler: {(result: Any?, error: Error?) in
//                identityManager.credentialsProvider.clearCredentials()
//                identityManager.credentialsProvider.clearKeychain()
//                identityManager.credentialsProvider.invalidateCachedTemporaryCredentials()
                AWSCognitoIdentityUserPool.default().clearAll()
                IAPHandler.shared.purchasedProducts.removeAll()
                UserDefaultsUtil.clearUserData()
                
                
                print("auth state AFTER logout: ", identityManager.authState().rawValue)
                print("user id AFTER logout: ", identityManager.identityId ?? "")
                print("user name AFTER logout: ", AwashUser.shared.user()?.username ?? "NO USERNAME")
                completion(true)
            })
            
        }
    }
}
