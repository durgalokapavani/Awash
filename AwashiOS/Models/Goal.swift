//
//  Goal.swift
//  AwashiOS
//
//  Created by Naveen K. Kakumani on 3/20/18.
//  Copyright © 2018 Awashapp. All rights reserved.
//

import Foundation

final class Goal: NSObject, ResponseObjectSerializable {
    var userId:String?
    var email:String?
    var goal:String?
    var createdAt:String?
    var updatedAt:String?
    
    required init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String: Any] else {
            return nil
        }
        
        self.userId = representation["userId"] as? String ?? ""
        self.email = representation["email"] as? String ?? ""
        self.goal = representation["goal"] as? String ?? ""
        self.createdAt = representation["createdAt"] as? String ?? ""
        self.updatedAt = representation["updatedAt"] as? String ?? ""
    }
}

extension Goal: ResponseCollectionSerializable {
    
    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Goal] {
        var collection: [Goal] = []
        let representation = representation as? [String: Any]
        
        if let representation = representation?[Constants.Model.data] as? [[String: AnyObject]] {
            for itemRepresentation in representation {
                if let item = Goal(response: response, representation: itemRepresentation as AnyObject) {
                    collection.append(item)
                }
            }
        }
        return collection
    }
}
