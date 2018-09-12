import Foundation
import Alamofire

/// Implementing the factory to create requests
class RequestFactory: AbstractRequestFactory {
    let sessionManager: SessionManager
    let queue: DispatchQueue
    let errorParser: AbstractErrorParser
    
    let baseURLString = "https://api.ip.sb/geoip/"
    
    init(sessionManager: SessionManager = SessionManagerFactory.sessionManager,
         queue: DispatchQueue = DispatchQueue.global(qos: .userInteractive),
         errorParser: AbstractErrorParser = ErrorParser()
        ) {
        self.sessionManager = sessionManager
        self.queue = queue
        self.errorParser = errorParser
    }
    
    @discardableResult
    func getIpInformation(ip: String = "", completion: @escaping (DataResponse<TrackingResponse>) -> Void) -> DataRequest {
        return request(request: TrackingRequest(ip: ip), completion: completion)
    }
}
