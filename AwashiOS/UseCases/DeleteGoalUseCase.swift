//
//  PostPurchaseUse.swift
//  AwashiOS
//

//  Copyright © 2017 Awashapp. All rights reserved.
//

import Alamofire

class DeleteGoalUseCase {
    
    
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
    private func makeRequest(authorization: String) {
        Alamofire.request(APIRouter.deleteGoal(authHeader: authorization))
            .validate()
            .response { response in
                
            }
    }
}
