import Foundation
import Alamofire

/// Abstract factory for creating requests
protocol AbstractRequestFactory {
    var sessionManager: SessionManager { get }
    var errorParser: AbstractErrorParser { get }
    var queue: DispatchQueue { get }
    
    @discardableResult
    func request<T: Decodable>(request: URLRequestConvertible, completion: @escaping (DataResponse<T>) -> Void) -> DataRequest
}

extension AbstractRequestFactory {
    
    @discardableResult
    func request<T: Decodable>(request: URLRequestConvertible, completion: @escaping(DataResponse<T>) -> Void) -> DataRequest {
        return sessionManager.request(request).responseCodable(errorParser: errorParser, queue: queue, completion: completion)
    }
}

extension DataRequest {
    @discardableResult
    func responseCodable<T: Decodable> (errorParser: AbstractErrorParser,
                                        queue: DispatchQueue? = nil,
                                        completion: @escaping (DataResponse<T>) -> Void) -> Self {
        let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
            if let error = errorParser.parse(response, data, error) {
                return .failure(error)
            }
            
            let result = Request.serializeResponseData(response: response, data: data, error: nil)
            
            switch result {
            case .success(let data):
                do {
                    let value = try JSONDecoder().decode(T.self, from: data)
                    return .success(value)
                } catch {
                    let customError = errorParser.parse(error)
                    return .failure(customError)
                }
            case .failure(let error):
                let customError = errorParser.parse(error)
                return .failure(customError)
            }
        }
        return response(queue: queue, responseSerializer: responseSerializer, completionHandler: completion)
    }
}

