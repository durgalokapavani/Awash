//
//  PostPurchaseUse.swift
//  AwashiOS
//

//  Copyright © 2017 Awashapp. All rights reserved.
//

import Alamofire

protocol PostPurchaseUseCaseDelegate {
    
    func postPurchaseSuccess(_ purchase: Purchase?)
    func postPurchaseFailure(_ error: (title: String, message: String), backendError:BackendError?)
}

struct PostPurchase: Codable {
    let productId: String
    let receiptData: String
    
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        let dict = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }

        return dict
    }
}

class PostPurchaseUseCase {
    
    var delegate: PostPurchaseUseCaseDelegate?
    private var params: [String: Any] = [:]
    
    init(purchase: PostPurchase) {
        if let body = purchase.dictionary{
            params = body
        }
    }
    
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
        Alamofire.request(APIRouter.postPurchase(param: params, authHeader: authorization))
            .validate()
            .responseObject { (response: DataResponse<Purchase>) in
                switch response.result {
                case .success:
                    self.delegate?.postPurchaseSuccess(response.result.value)
                case .failure(let error):
                    print("Error \(error)")
                    let err = error  as? BackendError
                    self.delegate?.postPurchaseFailure((title: "", message: ""), backendError: err)
                }
        }
    }
}
