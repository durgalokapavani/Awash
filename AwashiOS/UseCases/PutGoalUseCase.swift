//
//  PostPurchaseUse.swift
//  AwashiOS
//

//  Copyright © 2017 Awashapp. All rights reserved.
//

import Alamofire


typealias PutGoalRequestCompletionHandler = (_ success: Bool) -> ()

class PutGoalUseCase {
    
    private var params: [String: Any] = [:]
    
    init(goal: String) {
        params = ["goal": goal]
    }
    
    func performAction(completion: @escaping PostGoalRequestCompletionHandler) {
        //Fetch Authorization token and make request
        if let currentUser = AwashUser.shared.user() {
            currentUser.getSession().continueOnSuccessWith { (getSessionTask) -> AnyObject? in
                let getSessionResult = getSessionTask.result
                //print(getSessionResult?.idToken?.tokenString ?? "")
                self.makeRequest(completion: completion, authorization:getSessionResult?.idToken?.tokenString ?? "")
                return nil
            }
        }
        
        
    }
    
    //MARK: Private methods
    private func makeRequest(completion: @escaping PostGoalRequestCompletionHandler, authorization: String) {
        Alamofire.request(APIRouter.putGoal(param: params, authHeader: authorization))
            .validate()
            .responseObject { (response: DataResponse<Goal>) in
                switch response.result {
                case .success:
                    completion(true)
                case .failure(_):
                    completion(false)
                }
        }
    }
}