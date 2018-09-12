import Foundation
import Alamofire

/// Implementing error handling protocol
class ErrorParser: AbstractErrorParser {
    
    func parse(_ error: Error) -> Error {
        if error is DecodingError {
            return NetworkError.serializationFailed
        }
        if error is AFError {
            return NetworkError.alamofireError
        }
        if (error as NSError).code == NSURLErrorTimedOut {
            return NetworkError.connectionTimeOut
        }
        if (error as NSError).code == NSURLErrorCannotFindHost {
            return NetworkError.hostNotFound
        }
        if (error as NSError).code == NSURLErrorNotConnectedToInternet {
            return NetworkError.noInternet
        }
        return error
    }
    
    func parse(_ response: HTTPURLResponse?, _ data: Data?, _ error: Error?) -> Error? {
        if let error = error {
            return parse(error)
        }
        if data == nil {
            return NetworkError.noData
        }
        return nil
    }
}
