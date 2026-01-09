import Foundation
import ObjectMapper

struct CommentAPIModel: Mappable, Identifiable {
    var id: String?
    var text: String?
    var time: String?
    var userData: User_data?
    var likes: String? // Assuming api might return likes
    var replies: [CommentAPIModel]?
    var isLiked: Bool?
    
    init?(map: Map) {}

    mutating func mapping(map: Map) {
        id       <- map["id"]
        text     <- map["text"]
        time     <- map["time"]
        userData <- map["publisher"] // Usually 'publisher' or 'user_data'
        likes    <- map["likes"]
        // Try multiple keys for replies
        if map.JSON["replies"] != nil {
            replies <- map["replies"]
        } else if map.JSON["reply_data"] != nil {
            replies <- map["reply_data"]
        } else if map.JSON["replies_data"] != nil {
             replies <- map["replies_data"]
        }
        
        isLiked  <- map["is_liked"]
    }
}

struct CommentsResponse: Mappable {
    var apiStatus: Int?
    var data: [CommentAPIModel]?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        apiStatus <- map["api_status"]
        data      <- map["data"]
    }
}
