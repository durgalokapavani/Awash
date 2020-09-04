//
//  GetMeditations.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import Alamofire

protocol GetRatingsUseCaseDelegate {
    
    func getRatingsSuccess(_ activities: RatingsCollection)
    func getRatingsFailure(_ error: (title: String, message: String), backendError:BackendError?)
}


class GetRatingsUseCase {
    
    var delegate: GetRatingsUseCaseDelegate?
    var ExclusiveStartKey:String?
    var params = [String: AnyObject]()
    
    func performAction() {
        //Fetch Authorization token and make request
        if let currentUser = AwashUser.shared.user() {
            currentUser.getSession().continueOnSuccessWith { (getSessionTask) -> AnyObject? in
                let getSessionResult = getSessionTask.result
                //print(getSessionResult?.idToken?.tokenString ?? "")
                self.makeRequest(authorization:getSessionResult?.idToken?.tokenString ?? "")
                return nil
            }
        }
        
        
    }
    
    //MARK: Private methods
    private func makeRequest( authorization: String) {
        
        if let startKey = ExclusiveStartKey {
            params["ExclusiveStartKey"] = startKey as AnyObject
        }
        
        Alamofire.request(APIRouter.getRatings(params: params, authHeader: authorization))
            .validate()
            .responseCollection { (response: DataResponse<[Rating]>) in
                switch response.result {
                case .success:
                    let ratingsCollection = RatingsCollection()
                    ratingsCollection.ratings = response.result.value!
                    do {
                        let json = try JSONSerialization.jsonObject(with: response.data!, options:[])
                        if let currentDict = json as? NSDictionary {
                            ratingsCollection.count = currentDict[Constants.Model.count] as! Int
                            ratingsCollection.total = currentDict[Constants.Model.total] as! Int
                            ratingsCollection.startDate = currentDict["startDate"] as? String
                            ratingsCollection.endDate = currentDict["endDate"] as? String
                            if let startKeyDict = currentDict[Constants.Model.lastEvaluatedKey] as? NSDictionary {
                                let jsonData = try JSONSerialization.data(withJSONObject: startKeyDict, options: [])
                                let startKey = String(data: jsonData, encoding: String.Encoding.ascii)!
                                ratingsCollection.LastEvaluatedKey = startKey
                            }
                            
                        }
                        
                    } catch {
                        
                    }
                    self.delegate?.getRatingsSuccess(ratingsCollection)
                case .failure(let error):
                    print("Error \(error)")
                    self.delegate?.getRatingsFailure((title: "", message: ""), backendError: error as? BackendError )
                }
        }
    }
    
    
}
