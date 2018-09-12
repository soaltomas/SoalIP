import Foundation
import Alamofire

struct TrackingRequest: URLRequestConvertible {

    private let baseURLString = "https://api.ip.sb/geoip/"
    private var ip = ""
    private var method: HTTPMethod { return .get }
    
    init(ip: String) {
        self.ip = ip
    }
    
    
    func asURLRequest() throws -> URLRequest {
        
        let url = try baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(ip))
        urlRequest.httpMethod = method.rawValue
        urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        
        return urlRequest
    }
}
