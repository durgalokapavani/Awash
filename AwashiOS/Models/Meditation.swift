//
//  Meditation.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import Foundation

final class Meditation: NSObject, ResponseObjectSerializable {
    var meditationName:String?
    var meditationDescription:String?
    var bundleName:String?
    var bundleId:String?
    var bundlePrice:Double?
    var category:String?
    var title:String?
    var url:String?
    var type:String
    var createdAt:String?
    var updatedAt:String?
    
    required init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String: Any] else {
            return nil
        }
        
        self.meditationName = representation["meditationName"] as? String ?? ""
        self.meditationDescription = representation["meditationDescription"] as? String ?? ""
        self.bundleName = representation["bundleName"] as? String ?? ""
        self.bundleId = representation["bundleId"] as? String ?? ""
        self.bundlePrice = representation["bundlePrice"] as? Double ?? 0
        self.category = representation["category"] as? String ?? ""
        self.title = representation["title"] as? String ?? ""
        self.url = representation["url"] as? String ?? ""
        self.type = representation["type"] as? String ?? "paid"
        self.createdAt = representation["createdAt"] as? String ?? ""
        self.updatedAt = representation["updatedAt"] as? String ?? ""
    }
}

extension Meditation: ResponseCollectionSerializable {
    
    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Meditation] {
        var collection: [Meditation] = []
        let representation = representation as? [String: Any]
        
        if let representation = representation?[Constants.Model.data] as? [[String: AnyObject]] {
            for itemRepresentation in representation {
                if let item = Meditation(response: response, representation: itemRepresentation as AnyObject) {
                    collection.append(item)
                }
            }
        }
        return collection
    }
}
