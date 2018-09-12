import Foundation


/// Network error list
///
/// - noData: data was not received
/// - serializationFailed: data serialization error
/// - connectionTimeOut: the connection timed out
/// - alamofireError: Alamofire error
/// - hostNotFound: remote host could not be found
/// - noInternet: device is not connected to the internet
enum NetworkError: Error {
    case noData
    case serializationFailed
    case connectionTimeOut
    case alamofireError
    case hostNotFound
    case noInternet
}

extension Error {
    
    /// Converts an error to a text message
    ///
    /// - Returns: a text message that matches an error from NetworkError enum
    func message() -> String {
        let error = self as? NetworkError
        if error == nil {
            return "Not NetworkError protocol!"
        }
        switch error {
        case .alamofireError?:
            return "Network error!"
        case .noData?:
            return "Data was not received!"
        case .serializationFailed?:
            return "Data serialization error"
        case .connectionTimeOut?:
            return "The connection time out!"
        case .hostNotFound?:
            return "The connection failed because the host could not be found!"
        case .noInternet?:
            return "The connection failed because the device is not connected to the internet!"
        default:
            return "Oops! Something went wrong!"
        }
    }
}
