import Foundation

//---Error handling protocol
protocol AbstractErrorParser {
    /// Converts errors to a single format
    ///
    /// - Parameter error: original error
    /// - Returns: internal app error
    func parse(_ error: Error) -> Error
    /// Analyzes the http response for errors
    ///
    /// - Parameters:
    ///   - response: server response
    ///   - data: server response data
    ///   - error: network or server error in response
    /// - Returns: internal app error
    func parse(_ response: HTTPURLResponse?, _ data: Data?, _ error: Error?) -> Error?
}
