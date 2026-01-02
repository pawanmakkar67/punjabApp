import Foundation
import ObjectMapper

struct RegistrationResponseModel: Mappable {
    var apiStatus: Int = 0
    var message: String?
    var userId: String?
    var membership: Bool?
    var errors: APIErrorDetail?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        // Handle api_status -> can be Int or String
        if let status = try? map.value("api_status") as Int {
            apiStatus = status
        } else if let strStatus = try? map.value("api_status") as String,
                  let intStatus = Int(strStatus) {
            apiStatus = intStatus
        }

        message     <- map["message"]
        userId      <- map["user_id"]
        membership  <- map["membership"]
        errors      <- map["errors"]
    }
}


// MARK: - Nested Error Model
struct APIErrorDetail: Mappable {
    var errorId: String?
    var errorText: String?

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        // Handle error_id -> Int or String
        if let intId = try? map.value("error_id") as Int {
            errorId = String(intId)
        } else {
            errorId <- map["error_id"]
        }
        errorText <- map["error_text"]
    }
}
