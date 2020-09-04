//
//  Activity.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import Foundation

final class Activity: NSObject, ResponseObjectSerializable {
    var category:String?
    var userId:String?
    var title:String?
    var meditationName:String?
    var playTime:Int?
    var activityDate:String?
    var activityDateWithNoTimestamp: Date
    var createdAt:String?
    var updatedAt:String?
    
    required init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String: Any] else {
            return nil
        }
        
        self.userId = representation["userId"] as? String ?? ""
        self.playTime = representation["playTime"] as? Int ?? 0
        self.category = representation["category"] as? String ?? ""
        self.title = representation["title"] as? String ?? ""
        self.meditationName = representation["meditationName"] as? String ?? ""
        self.activityDate = representation["activityDate"] as? String ?? ""
        let cal = Calendar(identifier: .gregorian)
        activityDateWithNoTimestamp = cal.startOfDay(for: Utilities.utcToLocalDate(date: activityDate!))
        self.createdAt = representation["createdAt"] as? String ?? ""
        self.updatedAt = representation["updatedAt"] as? String ?? ""
    }
}

extension Activity: ResponseCollectionSerializable {
    
    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Activity] {
        var collection: [Activity] = []
        let representation = representation as? [String: Any]
        
        if let representation = representation?[Constants.Model.data] as? [[String: AnyObject]] {
            for itemRepresentation in representation {
                if let item = Activity(response: response, representation: itemRepresentation as AnyObject) {
                    collection.append(item)
                }
            }
        }
        return collection
    }
}
