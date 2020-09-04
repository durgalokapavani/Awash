//
//  GetMeditations.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import Alamofire

typealias DownloadUrlRequestCompletionHandler = (_ success: Bool, _ url: String?) -> ()

class GetDownloadUrlUseCase {
    
    var ExclusiveStartKey:String?
    let medName:String
    
    init(meditationName: String) {
        self.medName = meditationName
    }
    
    func performAction(completion: @escaping DownloadUrlRequestCompletionHandler) {
       
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
    private func makeRequest(completion: @escaping DownloadUrlRequestCompletionHandler, authorization: String) {
        let params = ["meditationName": self.medName]
        
        Alamofire.request(APIRouter.getDownloadUrl(authHeader: authorization, params: params as [String : AnyObject]))
            .validate()
            .responseJSON { (response) in
                if let json = response.result.value as? [String:String] {
                    completion(true, json["downloadUrl"])
                } else {
                    completion(false, nil)
                }
                
        }
    }
    
}
