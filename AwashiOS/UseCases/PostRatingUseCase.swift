//
//  PostPurchaseUse.swift
//  AwashiOS
//

//  Copyright © 2017 Awashapp. All rights reserved.
//

import Alamofire


typealias PostRatingRequestCompletionHandler = (_ success: Bool) -> ()

class PostRatingUseCase {
    
    private var params: [String: Any] = [:]
    
    init(rating: Int) {
        params = ["rating": rating]
    }
    
    func performAction(completion: @escaping PostRatingRequestCompletionHandler) {
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
    private func makeRequest(completion: @escaping PostRatingRequestCompletionHandler, authorization: String) {
        
        Alamofire.request(APIRouter.postRating(param: params, authHeader: authorization))
            .validate()
            .responseObject { (response: DataResponse<Rating>) in
                switch response.result {
                case .success:
                    completion(true)
                case .failure(_):
                    completion(false)
                }
        }
    }
}
