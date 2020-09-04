//
//  APIRouter.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import Foundation
import Alamofire

enum APIRouter: URLRequestConvertible {
    
    case getMeditations(params: [String: AnyObject])
    case postActivity(param: [String: Any])
    case getActivities(userId:String, params: [String: AnyObject])
    case postPurchase(param: [String: Any], authHeader: String)
    case getPurchases(params: [String: AnyObject], authHeader: String)
    case getCategories()
    case getDownloadUrl(authHeader: String, params: [String: AnyObject])
    case getGoals(authHeader: String)
    case postGoal(param: [String: Any], authHeader: String)
    case putGoal(param: [String: Any], authHeader: String)
    case deleteGoal(authHeader: String)
    case getRatings(params: [String: AnyObject], authHeader: String)
    case postRating(param: [String: Any], authHeader: String)
    case validateAccessCode(params: [String: String])
    
    
    var method: HTTPMethod {
        switch self {
        case .getMeditations:
            return .get
        case .postActivity:
            return .post
        case .getActivities:
            return .get
        case .postPurchase:
            return .post
        case .getPurchases:
            return .get
        case .getCategories:
            return .get
        case .getDownloadUrl:
            return .get
        case .getGoals:
            return .get
        case .postGoal:
            return .post
        case .putGoal:
            return .put
        case .deleteGoal:
            return .delete
        case .getRatings:
            return .get
        case .postRating:
            return .post
        case .validateAccessCode:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .getMeditations:
            return Constants.Config.meditations
        case .postActivity:
            return Constants.Config.activities
        case let .getActivities(userId, _):
            return Constants.Config.activities + "/" + userId
        case .postPurchase:
            return Constants.Config.purchases
        case .getPurchases:
            return Constants.Config.purchases
        case .getCategories:
            return Constants.Config.categories
        case .getDownloadUrl:
            return Constants.Config.generateUrl
        case .getGoals:
            return Constants.Config.goals
        case .postGoal:
            return Constants.Config.goals
        case .putGoal:
            return Constants.Config.goals
        case .deleteGoal:
            return Constants.Config.goals
        case .getRatings:
            return Constants.Config.ratings
        case .postRating:
            return Constants.Config.ratings
        case .validateAccessCode:
            return Constants.Config.auth
        }
    }
    
    // MARK: URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let url = Foundation.URL(string: RemoteConfigUtility.sharedInstance.getRemoteConfigValueForKey(key: RemoteConfigKey.apiBaseURL).stringValue!)
        
        var urlRequest = URLRequest(url: url!.appendingPathComponent(path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .getMeditations(let params):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
        case .postActivity(let params):
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: params)
        case .getActivities(_, let params):
            urlRequest = try URLEncoding.default.encode(urlRequest, with:params)
        case .postPurchase(let params, let authHeader):
            urlRequest.setValue(authHeader, forHTTPHeaderField: Constants.Config.authHeader)
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: params)
        case .getPurchases(let params, let authHeader):
            urlRequest.setValue(authHeader, forHTTPHeaderField: Constants.Config.authHeader)
            urlRequest = try URLEncoding.default.encode(urlRequest, with:params)
        case .getCategories():
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        case .getDownloadUrl(let authHeader, let params):
            urlRequest.setValue(authHeader, forHTTPHeaderField: Constants.Config.authHeader)
            urlRequest = try URLEncoding.default.encode(urlRequest, with:params)
        case .getGoals(let authHeader):
            urlRequest.setValue(authHeader, forHTTPHeaderField: Constants.Config.authHeader)
            urlRequest = try URLEncoding.default.encode(urlRequest, with:nil)
        case .postGoal(let params, let authHeader):
            urlRequest.setValue(authHeader, forHTTPHeaderField: Constants.Config.authHeader)
            urlRequest = try JSONEncoding.default.encode(urlRequest, with:params)
        case .putGoal(let params, let authHeader):
            urlRequest.setValue(authHeader, forHTTPHeaderField: Constants.Config.authHeader)
            urlRequest = try JSONEncoding.default.encode(urlRequest, with:params)
        case .deleteGoal(let authHeader):
            urlRequest.setValue(authHeader, forHTTPHeaderField: Constants.Config.authHeader)
            urlRequest = try URLEncoding.default.encode(urlRequest, with:nil)
        case .getRatings(let params, let authHeader):
            urlRequest.setValue(authHeader, forHTTPHeaderField: Constants.Config.authHeader)
            urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
        case .postRating(let params, let authHeader):
            urlRequest.setValue(authHeader, forHTTPHeaderField: Constants.Config.authHeader)
            urlRequest = try JSONEncoding.default.encode(urlRequest, with:params)
        case .validateAccessCode(let params):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
            
        }
        
        
        return urlRequest
    }
}
