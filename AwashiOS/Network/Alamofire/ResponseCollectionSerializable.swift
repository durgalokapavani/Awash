
//
//  ResponseCollectionSerializable.swift

//

import Alamofire

/*
 * Extend this class and implement init?(response: NSHTTPURLResponse, representation: AnyObject) constructor
 * to marshal response to a model collection object. Example: List of assets, users, accounts
 */
protocol ResponseCollectionSerializable {
    static func collection(from response: HTTPURLResponse, withRepresentation representation: Any) -> [Self]
}

extension DataRequest {
    @discardableResult
    func responseCollection<T: ResponseCollectionSerializable>(
        _ queue: DispatchQueue? = nil,
        completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self
    {
        let responseSerializer = DataResponseSerializer<[T]> { request, response, data, error in
            
            var additionalInfo = [String:String]()
            var eventName = Constants.Analytics.networkCallSuccess
            var statuscode:Int = 200
            
            if let requestURL = response?.url{
                additionalInfo[Constants.Analytics.requestURL] = "\(requestURL)"
            }
            
            if let code = response?.statusCode{
                additionalInfo[Constants.Analytics.code] = "\(code)"
                statuscode =  code
                eventName = (code >= 400 ? Constants.Analytics.networkCallFailure : Constants.Analytics.networkCallSuccess)
            }
            if let data = data{
                let responseData = String(data: data, encoding: .utf8)
                additionalInfo[Constants.Analytics.response] = responseData
            }
            if let error = error{
                if let responseBody = additionalInfo[Constants.Analytics.response]{
                    if responseBody.isEmpty{
                        additionalInfo[Constants.Analytics.response] = error.localizedDescription
                    }
                }
                
            }
            //print(eventName)
            if statuscode >= 400 {
                AnalyticsHandler.shared.trackEvent(of: .event, name: eventName, additionalInfo: additionalInfo)
            }
            

            var errorJson = ""
            guard error == nil else {
                if let data = data, let utf8Text = String(data: data, encoding: .utf8) {
                    errorJson = utf8Text
                    print("Failure Response: \(errorJson)")
                }
                
                guard let statusCode = response?.statusCode else{
                    let error = error! as NSError
                    let networkError = NSError(domain: "Network.Error", code: NSURLErrorNotConnectedToInternet, userInfo: [NSLocalizedDescriptionKey : error.localizedDescription])
                    return .failure(BackendError.network(error: networkError))
                }
                var errorMessage = errorJson
                if errorJson.isEmpty{
                    errorMessage = error?.localizedDescription ?? ""
                }
                
                let networkError = NSError(domain: "Network.Error", code: statusCode, userInfo: [NSLocalizedDescriptionKey : errorMessage])
                return .failure(BackendError.network(error: networkError))
            }
            
            let jsonSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = jsonSerializer.serializeResponse(request, response, data, nil)
            
            guard case let .success(jsonObject) = result else {
                return .failure(BackendError.jsonSerialization(error: result.error! as NSError))
            }
            
            guard let response = response else {
                let reason = "Response collection could not be serialized due to nil response."
                return .failure(BackendError.objectSerialization(reason: reason))
            }
            
            return .success(T.collection(from: response, withRepresentation: jsonObject))
        }
        
        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}
