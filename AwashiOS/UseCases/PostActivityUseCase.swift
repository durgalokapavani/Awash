//
//  PostActivityUseCase.swift
//  AwashiOS
//

//  Copyright © 2017 Awashapp. All rights reserved.
//

import Alamofire

protocol PostActivityUseCaseDelegate {
    
    func postActivitySuccess(_ activity: Activity?)
    func postActivityFailure(_ error: (title: String, message: String), backendError:BackendError?)
}

struct PostActivity: Codable {
    let category: String
    let title: String
    let userId: String
    let meditationName: String
    let playTime: Int
    
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        let dict = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }

        return dict
    }
}

class PostActivityUseCase {
    
    var delegate: PostActivityUseCaseDelegate?
    private var params: [String: Any] = [:]
    
    init(activity: PostActivity) {
        if let body = activity.dictionary{
            params = body
        }
    }
    
    func performAction() {
        Alamofire.request(APIRouter.postActivity(param: params))
            .validate()
            .responseObject { (response: DataResponse<Activity>) in
                switch response.result {
                case .success:
                    self.delegate?.postActivitySuccess(response.result.value)
                case .failure(let error):
                    print("Error \(error)")
                    let err = error  as? BackendError
                    self.delegate?.postActivityFailure((title: "", message: ""), backendError: err)
                }
        }
    }
}
