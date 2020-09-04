//
//  Goal.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 3/20/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import Foundation

final class Rating: NSObject, ResponseObjectSerializable {
    var userId:String?
    var email:String?
     var rating:Int
    var activityDate:String?
    var createdAt:String?
    var updatedAt:String?
    var ttl:Int
    
    required init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String: Any] else {
            return nil
        }
        
        self.userId = representation["userId"] as? String ?? ""
        self.email = representation["email"] as? String ?? ""
        self.rating = representation["rating"] as? Int ?? 0
        self.activityDate = representation["activityDate"] as? String ?? ""
        self.createdAt = representation["createdAt"] as? String ?? ""
        self.updatedAt = representation["updatedAt"] as? String ?? ""
        self.ttl = representation["ttl"] as? Int ?? 0
    }
}

extension Rating: ResponseCollectionSerializable {
    
    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Rating] {
        var collection: [Rating] = []
        let representation = representation as? [String: Any]
        
        if let representation = representation?[Constants.Model.data] as? [[String: AnyObject]] {
            for itemRepresentation in representation {
                if let item = Rating(response: response, representation: itemRepresentation as AnyObject) {
                    collection.append(item)
                }
            }
        }
        return collection
    }
}
