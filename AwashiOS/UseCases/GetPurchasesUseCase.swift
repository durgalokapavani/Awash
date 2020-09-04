//
//  GetMeditations.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import Alamofire

protocol GetPurchasesUseCaseDelegate {
    
    func getPurchasesSuccess(_ purchases: PurchasesCollection)
    func getPurchasesFailure(_ error: (title: String, message: String), backendError:BackendError?)
}

typealias PurchasesRequestCompletionHandler = (_ success: Bool, _ purchases: PurchasesCollection?) -> ()

class GetPurchasesUseCase {
    
    var delegate: GetPurchasesUseCaseDelegate?
    var ExclusiveStartKey:String?
    
    func performAction(completion: @escaping PurchasesRequestCompletionHandler) {
       
        //Fetch Authorization token and make request
        if let currentUser = AwashUser.shared.user() {
            currentUser.getSession().continueOnSuccessWith { (getSessionTask) -> AnyObject? in
                let getSessionResult = getSessionTask.result
                print("IDENTITY TOKEN", getSessionResult?.idToken?.tokenString ?? "")
                self.makeRequest(completion: completion, authorization:getSessionResult?.idToken?.tokenString ?? "")
                return nil
            }
        }
        
    }
    
    //MARK: Private methods
    private func makeRequest(completion: @escaping PurchasesRequestCompletionHandler, authorization: String) {
        var params = [String: AnyObject]()
        if let startKey = ExclusiveStartKey {
            params["ExclusiveStartKey"] = startKey as AnyObject
        }
        
        Alamofire.request(APIRouter.getPurchases(params: params, authHeader: authorization))
            .validate()
            .responseCollection { (response: DataResponse<[Purchase]>) in
                switch response.result {
                case .success:
                    let purchasesCollection = PurchasesCollection()
                    purchasesCollection.purchases = response.result.value!
                    do {
                        let json = try JSONSerialization.jsonObject(with: response.data!, options:[])
                        if let currentDict = json as? NSDictionary {
                            purchasesCollection.count = currentDict[Constants.Model.count] as! Int
                            purchasesCollection.total = currentDict[Constants.Model.total] as! Int
                            if let startKeyDict = currentDict[Constants.Model.lastEvaluatedKey] as? NSDictionary {
                                let jsonData = try JSONSerialization.data(withJSONObject: startKeyDict, options: [])
                                let startKey = String(data: jsonData, encoding: String.Encoding.ascii)!
                                purchasesCollection.LastEvaluatedKey = startKey
                            }
                        }
                        
                    } catch {
                        
                    }
                    completion(true, purchasesCollection)
                    self.delegate?.getPurchasesSuccess(purchasesCollection)
                case .failure(let error):
                    print("Error \(error)")
                    completion(false, nil)
                    self.delegate?.getPurchasesFailure((title: "", message: ""), backendError: error as? BackendError )
                }
        }
    }
    
}
