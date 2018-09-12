import Foundation

struct TrackingResponse: Decodable {
    var ip: String?
    var country: String?
    var city: String?
    var organization: String?
}
