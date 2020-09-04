//
//  Activity.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import Foundation

final class Purchase: NSObject, ResponseObjectSerializable {
    var productId:String?
    var userId:String?
    var email:String?
    var status:String?
    var isSubscriptionExpired:Bool
    var verifiedReceipt: [String: Any] = [:]
    var originalReceipt: [String: Any] = [:]
    var receiptData:String?
    var createdAt:String?
    var updatedAt:String?
    
    required init?(response: HTTPURLResponse, representation: Any) {
        guard let representation = representation as? [String: Any] else {
            return nil
        }
        
        self.userId = representation["userId"] as? String ?? ""
        self.productId = representation["productId"] as? String ?? ""
        self.email = representation["email"] as? String ?? ""
        self.status = representation["status"] as? String ?? ""
        self.isSubscriptionExpired = representation["isSubscriptionExpired"] as? Bool ?? false
        if let verifiedReceiptObj = representation["verifiedReceipt"] as? [String: Any] {
            self.verifiedReceipt = verifiedReceiptObj
        }
        if let originalReceiptObj = representation["originalReceipt"] as? [String: Any] {
            self.originalReceipt = originalReceiptObj
        }
        self.receiptData = representation["receiptData"] as? String ?? ""
        self.createdAt = representation["createdAt"] as? String ?? ""
        self.updatedAt = representation["updatedAt"] as? String ?? ""
    }
}

extension Purchase: ResponseCollectionSerializable {
    
    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Purchase] {
        var collection: [Purchase] = []
        let representation = representation as? [String: Any]
        
        if let representation = representation?[Constants.Model.data] as? [[String: AnyObject]] {
            for itemRepresentation in representation {
                if let item = Purchase(response: response, representation: itemRepresentation as AnyObject) {
                    collection.append(item)
                }
            }
        }
        return collection
    }
}
