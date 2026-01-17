/* 
Copyright (c) 2026 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import ObjectMapper

struct ReelsModel : Mappable {
	var status : Int?
	var count : Int?
	var watched_reels_recieved : String?
	var watched_reels : [String]?
	var data : [ReelsData]?

	init?(map: Map) {

	}

	mutating func mapping(map: Map) {

		status <- map["status"]
		count <- map["count"]
		watched_reels_recieved <- map["watched_reels_recieved"]
		watched_reels <- map["watched_reels"]
		data <- map["data"]
	}

}


struct ReelsData : Mappable {
    var id : String?
    var post_id : String?
    var user_id : String?
    var recipient_id : String?
    var postText : String?
    var page_id : String?
    var group_id : String?
    var event_id : String?
    var page_event_id : String?
    var postLink : String?
    var postLinkTitle : String?
    var postLinkImage : String?
    var postLinkContent : String?
    var postVimeo : String?
    var postDailymotion : String?
    var postFacebook : String?
    var postFile : String?
    var postFileName : String?
    var postFileThumb : String?
    var postYoutube : String?
    var postVine : String?
    var postSoundCloud : String?
    var postPlaytube : String?
    var postDeepsound : String?
    var postMap : String?
    var postShare : String?
    var postPrivacy : String?
    var postType : String?
    var postFeeling : String?
    var postListening : String?
    var postTraveling : String?
    var postWatching : String?
    var postPlaying : String?
    var postPhoto : String?
    var time : String?
    var registered : String?
    var album_name : String?
    var multi_image : String?
    var multi_image_post : String?
    var boosted : String?
    var product_id : String?
    var poll_id : String?
    var blog_id : String?
    var forum_id : String?
    var thread_id : String?
    var videoViews : String?
    var postRecord : String?
    var postSticker : String?
    var shared_from : Bool?
    var post_url : String?
    var parent_id : String?
    var cache : String?
    var comments_status : String?
    var blur : String?
    var color_id : String?
    var job_id : String?
    var offer_id : String?
    var fund_raise_id : String?
    var fund_id : String?
    var active : String?
    var stream_name : String?
    var agora_token : String?
    var live_time : String?
    var live_ended : String?
    var agora_resource_id : String?
    var agora_sid : String?
    var send_notify : String?
//    var 240p : String?
//    var 360p : String?
//    var 480p : String?
//    var 720p : String?
//    var 1080p : String?
//    var 2048p : String?
//    var 4096p : String?
    var processing : String?
    var ai_post : String?
    var videoTitle : String?
    var is_reel : String?
    var blur_url : String?
    var publisher : Publisher?
    var limit_comments : Int?
    var limited_comments : Bool?
    var is_group_post : Bool?
    var group_recipient_exists : Bool?
    var group_admin : Bool?
    var mentions_users : [String]?
    var post_is_promoted : Int?
    var postText_API : String?
    var orginaltext : String?
    var post_time : String?
    var page : Int?
    var url : String?
    var seo_id : String?
    var via_type : String?
    var recipient_exists : Bool?
    var recipient : String?
    var admin : Bool?
    var post_share : String?
    var is_post_saved : Bool?
    var is_post_reported : Bool?
    var is_post_boosted : Int?
    var is_liked : Bool?
    var is_wondered : Bool?
    var post_comments : String?
    var post_shares : String?
    var post_likes : String?
    var post_wonders : String?
    var is_post_pinned : Bool?
    var get_post_comments : [String]?
    var photo_album : [String]?
    var options : [String]?
    var voted_id : Int?
    var postFile_full : String?
    var reaction : Reaction?
    var job : [String]?
    var offer : [String]?
    var fund : [String]?
    var fund_data : [String]?
    var forum : [String]?
    var thread : [String]?
    var is_still_live : Bool?
    var live_sub_users : Int?
    var have_next_image : Bool?
    var have_pre_image : Bool?
    var is_monetized_post : Bool?
    var can_not_see_monetized : Int?
    var post_origin : String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        post_id <- map["post_id"]
        user_id <- map["user_id"]
        recipient_id <- map["recipient_id"]
        postText <- map["postText"]
        page_id <- map["page_id"]
        group_id <- map["group_id"]
        event_id <- map["event_id"]
        page_event_id <- map["page_event_id"]
        postLink <- map["postLink"]
        postLinkTitle <- map["postLinkTitle"]
        postLinkImage <- map["postLinkImage"]
        postLinkContent <- map["postLinkContent"]
        postVimeo <- map["postVimeo"]
        postDailymotion <- map["postDailymotion"]
        postFacebook <- map["postFacebook"]
        postFile <- map["postFile"]
        postFileName <- map["postFileName"]
        postFileThumb <- map["postFileThumb"]
        postYoutube <- map["postYoutube"]
        postVine <- map["postVine"]
        postSoundCloud <- map["postSoundCloud"]
        postPlaytube <- map["postPlaytube"]
        postDeepsound <- map["postDeepsound"]
        postMap <- map["postMap"]
        postShare <- map["postShare"]
        postPrivacy <- map["postPrivacy"]
        postType <- map["postType"]
        postFeeling <- map["postFeeling"]
        postListening <- map["postListening"]
        postTraveling <- map["postTraveling"]
        postWatching <- map["postWatching"]
        postPlaying <- map["postPlaying"]
        postPhoto <- map["postPhoto"]
        time <- map["time"]
        registered <- map["registered"]
        album_name <- map["album_name"]
        multi_image <- map["multi_image"]
        multi_image_post <- map["multi_image_post"]
        boosted <- map["boosted"]
        product_id <- map["product_id"]
        poll_id <- map["poll_id"]
        blog_id <- map["blog_id"]
        forum_id <- map["forum_id"]
        thread_id <- map["thread_id"]
        videoViews <- map["videoViews"]
        postRecord <- map["postRecord"]
        postSticker <- map["postSticker"]
        shared_from <- map["shared_from"]
        post_url <- map["post_url"]
        parent_id <- map["parent_id"]
        cache <- map["cache"]
        comments_status <- map["comments_status"]
        blur <- map["blur"]
        color_id <- map["color_id"]
        job_id <- map["job_id"]
        offer_id <- map["offer_id"]
        fund_raise_id <- map["fund_raise_id"]
        fund_id <- map["fund_id"]
        active <- map["active"]
        stream_name <- map["stream_name"]
        agora_token <- map["agora_token"]
        live_time <- map["live_time"]
        live_ended <- map["live_ended"]
        agora_resource_id <- map["agora_resource_id"]
        agora_sid <- map["agora_sid"]
        send_notify <- map["send_notify"]
//        240p <- map["240p"]
//        360p <- map["360p"]
//        480p <- map["480p"]
//        720p <- map["720p"]
//        1080p <- map["1080p"]
//        2048p <- map["2048p"]
//        4096p <- map["4096p"]
        processing <- map["processing"]
        ai_post <- map["ai_post"]
        videoTitle <- map["videoTitle"]
        is_reel <- map["is_reel"]
        blur_url <- map["blur_url"]
        publisher <- map["publisher"]
        limit_comments <- map["limit_comments"]
        limited_comments <- map["limited_comments"]
        is_group_post <- map["is_group_post"]
        group_recipient_exists <- map["group_recipient_exists"]
        group_admin <- map["group_admin"]
        mentions_users <- map["mentions_users"]
        post_is_promoted <- map["post_is_promoted"]
        postText_API <- map["postText_API"]
        orginaltext <- map["Orginaltext"]
        post_time <- map["post_time"]
        page <- map["page"]
        url <- map["url"]
        seo_id <- map["seo_id"]
        via_type <- map["via_type"]
        recipient_exists <- map["recipient_exists"]
        recipient <- map["recipient"]
        admin <- map["admin"]
        post_share <- map["post_share"]
        is_post_saved <- map["is_post_saved"]
        is_post_reported <- map["is_post_reported"]
        is_post_boosted <- map["is_post_boosted"]
        is_liked <- map["is_liked"]
        is_wondered <- map["is_wondered"]
        post_comments <- map["post_comments"]
        post_shares <- map["post_shares"]
        post_likes <- map["post_likes"]
        post_wonders <- map["post_wonders"]
        is_post_pinned <- map["is_post_pinned"]
        get_post_comments <- map["get_post_comments"]
        photo_album <- map["photo_album"]
        options <- map["options"]
        voted_id <- map["voted_id"]
        postFile_full <- map["postFile_full"]
        reaction <- map["reaction"]
        job <- map["job"]
        offer <- map["offer"]
        fund <- map["fund"]
        fund_data <- map["fund_data"]
        forum <- map["forum"]
        thread <- map["thread"]
        is_still_live <- map["is_still_live"]
        live_sub_users <- map["live_sub_users"]
        have_next_image <- map["have_next_image"]
        have_pre_image <- map["have_pre_image"]
        is_monetized_post <- map["is_monetized_post"]
        can_not_see_monetized <- map["can_not_see_monetized"]
        post_origin <- map["post_origin"]
    }

}
