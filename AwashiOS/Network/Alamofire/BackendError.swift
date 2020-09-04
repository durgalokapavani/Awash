

import Foundation

public enum BackendError: Error {
    case network(error: NSError)
    case dataSerialization(reason: String)
    case jsonSerialization(error: NSError)
    case objectSerialization(reason: String)
    case xmlSerialization(error: NSError)
    
    var userInfo: [String : String]? {
        switch self {
        case .dataSerialization(_) :
            return [:]
        case .objectSerialization(_):
            return [:]
        case .network(let error) :
            return error.userInfo as? [String : String]
        case .jsonSerialization(let error):
            return error.userInfo as? [String : String]
        case .xmlSerialization(let error):
            return error.userInfo as? [String : String]
            
        }
    }

}
