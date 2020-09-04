//
//  GetMeditations.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import Alamofire


typealias GoalRequestCompletionHandler = (_ success: Bool, _ goal: Goal?) -> ()

class GetGoalUseCase {
    
    func performAction(completion: @escaping GoalRequestCompletionHandler) {
       
        //Fetch Authorization token and make request
        if let currentUser = AwashUser.shared.user() {
            currentUser.getSession().continueOnSuccessWith { (getSessionTask) -> AnyObject? in
                let getSessionResult = getSessionTask.result
                self.makeRequest(completion: completion, authorization:getSessionResult?.idToken?.tokenString ?? "")
                return nil
            }
        }
        
    }
    
    //MARK: Private methods
    private func makeRequest(completion: @escaping GoalRequestCompletionHandler, authorization: String) {
        
        Alamofire.request(APIRouter.getGoals(authHeader: authorization))
            .validate()
            .responseCollection { (response: DataResponse<[Goal]>) in
                switch response.result {
                case .success:
                    let goals = response.result.value!
                    if goals.count == 1 {
                        completion(true, goals[0])
                    } else {
                        completion(true, nil)
                    }
                    
                case .failure( _):
                    completion(false, nil)
                    
                }
        }
    }
    
}
