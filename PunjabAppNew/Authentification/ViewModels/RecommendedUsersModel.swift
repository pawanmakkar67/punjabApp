//
//  RecommendedUsersModel.swift
//  PunjabAppNew
//
//  Created for nearby friends API response
//

import Foundation
import ObjectMapper

struct RecommendedUsersModel: Mappable {
    var api_status: Int?
    var users: [User_data]?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        api_status <- map["api_status"]
        users <- map["data"]
    }
}
