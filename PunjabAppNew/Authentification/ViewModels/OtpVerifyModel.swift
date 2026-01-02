//
//  Json4Swift.swift
//  PunjabAppNew
//
//  Created by pc on 14/11/25.
//

import Foundation
import ObjectMapper

struct OtpVerifyModel: Mappable {
    var apiStatus: Int = 0
    var timezone: String?
    var accessTokenn: String?
    var userId: String?
    var userPlatform: String?
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

        timezone       <- map["timezone"]
        accessTokenn   <- map["access_token"]
        userId         <- map["user_id"]
        userPlatform   <- map["user_platform"]
        errors         <- map["errors"]
    }
}
