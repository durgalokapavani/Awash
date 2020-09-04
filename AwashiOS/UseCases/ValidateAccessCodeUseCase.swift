//
//  GetMeditations.swift
//  AwashiOS
//
//  Copyright © 2017 Awashapp. All rights reserved.
//

import Alamofire

protocol ValidateAccessCodeUseCaseDelegate {
    
    func validationSuccess()
    func validationFailure()
}


class ValidateAccessCodeUseCase {
    
    var delegate: ValidateAccessCodeUseCaseDelegate?
    var params = [String: String]()
    
    func performAction() {
        Alamofire.request(APIRouter.validateAccessCode(params: params))
            .validate()
            .responseJSON { (response) in
                if let json = response.result.value as? [String: Bool] {
                    if let success = json["success"] {
                        success ? self.delegate?.validationSuccess() : self.delegate?.validationFailure()
                    } else {
                        self.delegate?.validationFailure()
                    }
                    
                } else {
                    self.delegate?.validationFailure()
                }
                
        }
    }
    
    
}
