//
//  GetMeditations.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import Alamofire

protocol GetCategoriesUseCaseDelegate {
    
    func getCategoriesSuccess(_ categoriesCollection: CategoriesCollection)
    func getCategoriesFailure(_ error: (title: String, message: String), backendError:BackendError?)
}


class GetCategoriesUseCase {
    
    var delegate: GetCategoriesUseCaseDelegate?
    var ExclusiveStartKey:String?
    
    func performAction() {
        var params = [String: AnyObject]()
        if let startKey = ExclusiveStartKey {
            params["ExclusiveStartKey"] = startKey as AnyObject
        }
        
        Alamofire.request(APIRouter.getCategories())
            .validate()
            .responseCollection { (response: DataResponse<[Category]>) in
                switch response.result {
                case .success:
                    let categoriesCollection = CategoriesCollection()
                    categoriesCollection.categories = response.result.value!
                    do {
                        let json = try JSONSerialization.jsonObject(with: response.data!, options:[])
                        if let currentDict = json as? NSDictionary {
                            categoriesCollection.count = currentDict[Constants.Model.count] as! Int
                            categoriesCollection.total = currentDict[Constants.Model.total] as! Int
                        }
                        
                    } catch {
                        
                    }
                    self.delegate?.getCategoriesSuccess(categoriesCollection)
                case .failure(let error):
                    print("Error \(error)")
                    self.delegate?.getCategoriesFailure((title: "", message: ""), backendError: error as? BackendError )
                }
        }
    }
    
}
