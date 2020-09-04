//
//  GetMeditations.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import Alamofire

protocol GetActivitiesUseCaseDelegate {
    
    func getActivitiesSuccess(_ activities: ActivitiesCollection)
    func getactivitiesFailure(_ error: (title: String, message: String), backendError:BackendError?)
}


class GetActivitiesUseCase {
    
    var delegate: GetActivitiesUseCaseDelegate?
    var userIdParam: String
    var ExclusiveStartKey:String?
    
    init(userId: String) {
        userIdParam = userId
    }
    func performAction() {
        var params = [String: AnyObject]()
        if let startKey = ExclusiveStartKey {
            params["ExclusiveStartKey"] = startKey as AnyObject
        }
        
        Alamofire.request(APIRouter.getActivities(userId: userIdParam, params: params))
            .validate()
            .responseCollection { (response: DataResponse<[Activity]>) in
                switch response.result {
                case .success:
                    let activitiesCollection = ActivitiesCollection()
                    activitiesCollection.activities = response.result.value!
                    do {
                        let json = try JSONSerialization.jsonObject(with: response.data!, options:[])
                        if let currentDict = json as? NSDictionary {
                            activitiesCollection.count = currentDict[Constants.Model.count] as! Int
                            activitiesCollection.total = currentDict[Constants.Model.total] as! Int
                            activitiesCollection.startDate = currentDict["startDate"] as? String
                            activitiesCollection.endDate = currentDict["endDate"] as? String
                            if let startKeyDict = currentDict[Constants.Model.lastEvaluatedKey] as? NSDictionary {
                                let jsonData = try JSONSerialization.data(withJSONObject: startKeyDict, options: [])
                                let startKey = String(data: jsonData, encoding: String.Encoding.ascii)!
                                activitiesCollection.LastEvaluatedKey = startKey
                            }
                            
                        }
                        
                    } catch {
                        
                    }
                    self.delegate?.getActivitiesSuccess(activitiesCollection)
                case .failure(let error):
                    print("Error \(error)")
                    self.delegate?.getactivitiesFailure((title: "", message: ""), backendError: error as? BackendError )
                }
        }
    }
    
}
