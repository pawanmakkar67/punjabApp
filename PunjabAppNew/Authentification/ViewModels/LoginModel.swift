import Foundation

import Foundation
import ObjectMapper

class LoginModel: Mappable {
    var apiStatus: Int = 0
    var message: String?
    var userId: String?
    var membership: Bool?
    var accessToken: String?
    var errors: APIErrorDetail?

    required init?(map: Map) {}

    func mapping(map: Map) {
        // api_status may come as Int or String → handle both
        var apiStatusAny: Any?
        apiStatusAny <- map["api_status"]
        
        if let value = apiStatusAny as? Int {
            apiStatus = value
        } else if let value = apiStatusAny as? String, let intValue = Int(value) {
            apiStatus = intValue
        }

        message       <- map["message"]
        userId        <- map["user_id"]
        accessToken   <- map["access_token"]
        membership    <- map["membership"]
        errors        <- map["errors"]
    }
}

// MARK: - Nested Error Model
//struct APIErrorDetail: Codable {
//    let errorId: String?
//    let errorText: String?
//
//    enum CodingKeys: String, CodingKey {
//        case errorId = "error_id"
//        case errorText = "error_text"
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        // ✅ Handle Int or String types gracefully
//        if let intValue = try? container.decode(Int.self, forKey: .errorId) {
//            errorId = String(intValue)
//        } else {
//            errorId = try? container.decode(String.self, forKey: .errorId)
//        }
//
//        errorText = try? container.decode(String.self, forKey: .errorText)
//    }
//}
