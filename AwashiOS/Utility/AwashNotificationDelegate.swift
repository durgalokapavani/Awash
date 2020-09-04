//
//  AwashNotificationDelegate.swift
//  AwashiOS
//
//  Copyright © 2018 Awashapp. All rights reserved.
//

import UserNotifications

class AwashNotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Play sound and show alert to the user
        completionHandler([.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // Determine the user action
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            print("Default")
        case "Snooze":
            let snooze:TimeInterval = 10.0
            let request = response.notification.request
            let newContent = request.content.mutableCopy() as! UNMutableNotificationContent
            let newTrigger = UNTimeIntervalNotificationTrigger(timeInterval: snooze, repeats: false)
            let newRequest = UNNotificationRequest(identifier: request.identifier,
                                                content: newContent, trigger: newTrigger)
            center.add(newRequest, withCompletionHandler: nil)
            print("Snooze")
        case "Delete":
            print("Delete")
        default:
            print("Unknown action")
        }
        completionHandler()
    }
}
