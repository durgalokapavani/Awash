//
//  GetMeditations.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import Alamofire

protocol GetMeditationsUseCaseDelegate {
    
    func getMeditationsSuccess(_ meditations: MeditationsCollection)
    func getMeditationsFailure(_ error: (title: String, message: String), backendError:BackendError?)
}


class GetMeditationsUseCase {
    
    var delegate: GetMeditationsUseCaseDelegate?
    var categoryName: String?
    var exclusiveStartKey: String?
    
    func performAction() {
        
        var params = [String: AnyObject]()
        if let category = categoryName {
            params["category"] = category as AnyObject
        }
        if let exclusiveStartKey = exclusiveStartKey {
            params[Constants.Model.exclusiveStartKey] = exclusiveStartKey as AnyObject
        }
            
        Alamofire.request(APIRouter.getMeditations(params: params))
            .validate()
            .responseCollection { (response: DataResponse<[Meditation]>) in
                switch response.result {
                case .success:
                    let meditationsCollection = MeditationsCollection()
                    meditationsCollection.meditations = response.result.value!
                    do {
                        let json = try JSONSerialization.jsonObject(with: response.data!, options:[])
                        if let currentDict = json as? NSDictionary {
                            meditationsCollection.count = currentDict[Constants.Model.count] as! Int
                            meditationsCollection.total = currentDict[Constants.Model.total] as! Int
                            if let startKeyDict = currentDict[Constants.Model.lastEvaluatedKey] as? NSDictionary {
                                let jsonData = try JSONSerialization.data(withJSONObject: startKeyDict, options: [])
                                let startKey = String(data: jsonData, encoding: String.Encoding.ascii)!
                                meditationsCollection.LastEvaluatedKey = startKey
                            }
                        }
                        
                    } catch {
                        
                    }
                    self.delegate?.getMeditationsSuccess(meditationsCollection)
                case .failure(let error):
                    print("Error \(error)")
                    self.delegate?.getMeditationsFailure((title: "", message: ""), backendError: error as? BackendError )
                }
        }
    }
    
}
