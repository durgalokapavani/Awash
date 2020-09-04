//
//  Category.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import Foundation
import StoreKit

final class Category: NSObject, ResponseObjectSerializable {
    var name: String?
    var details: String?
    var type: String?
    var productId: String?
    var product: SKProduct?
    var isCourse: Bool {
        if type != nil && type!.elementsEqual("course")  {
            return true
        }
        
        return false
    }
    
    var isIntro: Bool {
        if type != nil && type!.elementsEqual("intro")  {
            return true
        }
        
        return false
    }
    
    required init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String: Any] else {
            return nil
        }
        
        self.name = representation["name"] as? String ?? ""
        self.details = representation["details"] as? String ?? ""
        self.type = representation["type"] as? String ?? ""
        self.productId = representation["productId"] as? String ?? ""
    }
    
}

extension Category: ResponseCollectionSerializable {
    
    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Category] {
        var collection: [Category] = []
        let representation = representation as? [String: Any]
        
        if let representation = representation?[Constants.Model.data] as? [[String: AnyObject]] {
            for itemRepresentation in representation {
                if let item = Category(response: response, representation: itemRepresentation as AnyObject) {
                    collection.append(item)
                }
            }
        }
        return collection
    }
}
