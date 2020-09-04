//
//  AppDelegate.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import UIKit
import AWSAuthCore
import AWSUserPoolsSignIn
//import AWSPinpoint
import AVFoundation
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    //var pinpoint: AWSPinpoint?
    //Used for checking whether Push Notification is enabled in Amazon Pinpoint
    static let remoteNotificationKey = "RemoteNotification"
    var isInitialized: Bool = false
    let notificationDelegate = AwashNotificationDelegate()



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        application.beginReceivingRemoteControlEvents()
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        }catch {
            print(error)
        }
        
        // Register the sign in provider instances with their unique identifier
        //AWSFacebookSignInProvider.sharedInstance().setPermissions(["public_profile", "email"])
        //AWSSignInManager.sharedInstance().register(signInProvider: AWSFacebookSignInProvider.sharedInstance())
        
        AWSSignInManager.sharedInstance().register(signInProvider: AWSCognitoUserPoolsSignInProvider.sharedInstance())
        //let didFinishLaunching = AWSSignInManager.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
        
        //pinpoint = AWSPinpoint(configuration:AWSPinpointConfiguration.defaultPinpointConfiguration(launchOptions: launchOptions))
        if (!isInitialized) {
            AWSSignInManager.sharedInstance().resumeSession(completionHandler: { (result: Any?, error: Error?) in
                print("Result: \(result ?? "") \n Error:\(String(describing: error))")
            })
            isInitialized = true
        }
        
        FirebaseApp.configure()
        //Analytics Handler set up
        let _ = AnalyticsHandler.shared
        //RemoteConfig setup
        RemoteConfigUtility.sharedInstance.setup()
        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        // print("application application: \(application.description), openURL: \(url.absoluteURL), sourceApplication: \(sourceApplication)")
        AWSSignInManager.sharedInstance().interceptApplication(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        isInitialized = true
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
        do {
            try AwashCache.shared.storage?.removeAll()
        } catch {
            print(error)
        }
    }

}

