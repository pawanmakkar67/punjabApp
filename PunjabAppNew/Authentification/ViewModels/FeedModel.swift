/* 
Copyright (c) 2025 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import ObjectMapper

struct FeedModel : Mappable {
	var api_status : Int?
	var data : [Post]?

	init?(map: Map) {

	}

	mutating func mapping(map: Map) {

		api_status <- map["api_status"]
		data <- map["data"]
	}

}

struct myPostsModel : Mappable {
    var api_status : Int?
    var data : [Post]?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        api_status <- map["status"]
        data <- map["data"]
    }

}

struct API_notification_settings : Mappable {
    var e_liked : Int?
    var e_shared : Int?
    var e_wondered : Int?
    var e_commented : Int?
    var e_followed : Int?
    var e_accepted : Int?
    var e_mentioned : Int?
    var e_joined_group : Int?
    var e_liked_page : Int?
    var e_visited : Int?
    var e_profile_wall_post : Int?
    var e_memory : Int?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        e_liked <- map["e_liked"]
        e_shared <- map["e_shared"]
        e_wondered <- map["e_wondered"]
        e_commented <- map["e_commented"]
        e_followed <- map["e_followed"]
        e_accepted <- map["e_accepted"]
        e_mentioned <- map["e_mentioned"]
        e_joined_group <- map["e_joined_group"]
        e_liked_page <- map["e_liked_page"]
        e_visited <- map["e_visited"]
        e_profile_wall_post <- map["e_profile_wall_post"]
        e_memory <- map["e_memory"]
    }

}


struct Details : Mappable {
    var post_count : String?
    var album_count : String?
    var following_count : String?
    var followers_count : String?
    var groups_count : String?
    var likes_count : String?
    var mutual_friends_count : Int?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        post_count <- map["post_count"]
        album_count <- map["album_count"]
        following_count <- map["following_count"]
        followers_count <- map["followers_count"]
        groups_count <- map["groups_count"]
        likes_count <- map["likes_count"]
        mutual_friends_count <- map["mutual_friends_count"]
    }

}



struct Post : Mappable {
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
    var t240p : String?
    var t360p : String?
    var t480p : String?
    var t720p : String?
    var t1080p : String?
    var t2048p : String?
    var t4096p : String?
    var processing : String?
    var ai_post : String?
    var videoTitle : String?
    var is_reel : String?
    var blur_url : String?
    var publisher : User_data?
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
    var photo_multi : [Photo_multi]?
    var options : [String]?
    var voted_id : Int?
    var postFile_full : String?
    var reaction : Reaction1?
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
    var shared_info : String?
    var post_origin : String?
    var user_data : String?

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
        t240p <- map["240p"]
        t360p <- map["360p"]
        t480p <- map["480p"]
        t720p <- map["720p"]
        t1080p <- map["1080p"]
        t2048p <- map["2048p"]
        t4096p <- map["4096p"]
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
        photo_multi <- map["photo_multi"]
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
        shared_info <- map["shared_info"]
        post_origin <- map["post_origin"]
        user_data <- map["user_data"]
    }

}
struct Photo_multi : Mappable {
    var id : String?
    var image : String?
    var post_id : String?
    var parent_id : String?
    var image_org : String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        image <- map["image"]
        post_id <- map["post_id"]
        parent_id <- map["parent_id"]
        image_org <- map["image_org"]
    }

}



struct Publisher : Mappable {
    var user_id : String?
    var username : String?
    var email : String?
    var first_name : String?
    var last_name : String?
    var avatar : String?
    var cover : String?
    var background_image : String?
    var relationship_id : String?
    var address : String?
    var working : String?
    var working_link : String?
    var about : String?
    var school : String?
    var gender : String?
    var birthday : String?
    var country_id : String?
    var website : String?
    var facebook : String?
    var google : String?
    var twitter : String?
    var linkedin : String?
    var youtube : String?
    var vk : String?
    var instagram : String?
    var qq : String?
    var wechat : String?
    var discord : String?
    var mailru : String?
    var okru : String?
    var language : String?
    var ip_address : String?
    var follow_privacy : String?
    var friend_privacy : String?
    var post_privacy : String?
    var message_privacy : String?
    var confirm_followers : String?
    var show_activities_privacy : String?
    var birth_privacy : String?
    var visit_privacy : String?
    var verified : String?
    var lastseen : String?
    var emailNotification : String?
    var e_liked : String?
    var e_wondered : String?
    var e_shared : String?
    var e_followed : String?
    var e_commented : String?
    var e_visited : String?
    var e_liked_page : String?
    var e_mentioned : String?
    var e_joined_group : String?
    var e_accepted : String?
    var e_profile_wall_post : String?
    var e_sentme_msg : String?
    var e_last_notif : String?
    var notification_settings : String?
    var status : String?
    var active : String?
    var admin : String?
    var registered : String?
    var phone_number : String?
    var is_pro : String?
    var pro_type : String?
    var pro_remainder : String?
    var timezone : String?
    var referrer : String?
    var ref_user_id : String?
    var ref_level : String?
    var balance : String?
    var paypal_email : String?
    var notifications_sound : String?
    var order_posts_by : String?
    var android_m_device_id : String?
    var ios_m_device_id : String?
    var android_n_device_id : String?
    var ios_n_device_id : String?
    var web_device_id : String?
    var wallet : String?
    var lat : String?
    var lng : String?
    var last_location_update : String?
    var share_my_location : String?
    var last_data_update : String?
    var details : Details?
    var last_avatar_mod : String?
    var last_cover_mod : String?
    var points : String?
    var daily_points : String?
    var converted_points : String?
    var point_day_expire : String?
    var last_follow_id : String?
    var share_my_data : String?
    var last_login_data : String?
    var two_factor : String?
    var two_factor_hash : String?
    var new_email : String?
    var two_factor_verified : String?
    var new_phone : String?
    var info_file : String?
    var city : String?
    var state : String?
    var zip : String?
    var school_completed : String?
    var weather_unit : String?
    var paystack_ref : String?
    var code_sent : String?
    var time_code_sent : String?
    var permission : String?
    var skills : String?
    var languages : String?
    var currently_working : String?
    var banned : String?
    var banned_reason : String?
    var credits : String?
    var authy_id : String?
    var google_secret : String?
    var two_factor_method : String?
    var phone_privacy : String?
    var have_monetization : String?
    var avatar_post_id : String?
    var cover_post_id : String?
    var avatar_full : String?
    var is_verified : Int?
    var user_platform : String?
    var url : String?
    var name : String?
    var aPI_notification_settings : API_notification_settings?
    var is_notify_stopped : Int?
    var mutual_friends_data : String?
    var lastseen_unix_time : String?
    var lastseen_status : String?
    var is_reported : Bool?
    var am_i_blocked : Bool?
    var is_story_muted : Bool?
    var is_following_me : Int?
    var is_following : Int?
    var is_reported_user : Int?
    var is_open_to_work : Int?
    var is_providing_service : Int?
    var providing_service : Int?
    var open_to_work_data : String?
    var formated_langs : [String]?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        user_id <- map["user_id"]
        username <- map["username"]
        email <- map["email"]
        first_name <- map["first_name"]
        last_name <- map["last_name"]
        avatar <- map["avatar"]
        cover <- map["cover"]
        background_image <- map["background_image"]
        relationship_id <- map["relationship_id"]
        address <- map["address"]
        working <- map["working"]
        working_link <- map["working_link"]
        about <- map["about"]
        school <- map["school"]
        gender <- map["gender"]
        birthday <- map["birthday"]
        country_id <- map["country_id"]
        website <- map["website"]
        facebook <- map["facebook"]
        google <- map["google"]
        twitter <- map["twitter"]
        linkedin <- map["linkedin"]
        youtube <- map["youtube"]
        vk <- map["vk"]
        instagram <- map["instagram"]
        qq <- map["qq"]
        wechat <- map["wechat"]
        discord <- map["discord"]
        mailru <- map["mailru"]
        okru <- map["okru"]
        language <- map["language"]
        ip_address <- map["ip_address"]
        follow_privacy <- map["follow_privacy"]
        friend_privacy <- map["friend_privacy"]
        post_privacy <- map["post_privacy"]
        message_privacy <- map["message_privacy"]
        confirm_followers <- map["confirm_followers"]
        show_activities_privacy <- map["show_activities_privacy"]
        birth_privacy <- map["birth_privacy"]
        visit_privacy <- map["visit_privacy"]
        verified <- map["verified"]
        lastseen <- map["lastseen"]
        emailNotification <- map["emailNotification"]
        e_liked <- map["e_liked"]
        e_wondered <- map["e_wondered"]
        e_shared <- map["e_shared"]
        e_followed <- map["e_followed"]
        e_commented <- map["e_commented"]
        e_visited <- map["e_visited"]
        e_liked_page <- map["e_liked_page"]
        e_mentioned <- map["e_mentioned"]
        e_joined_group <- map["e_joined_group"]
        e_accepted <- map["e_accepted"]
        e_profile_wall_post <- map["e_profile_wall_post"]
        e_sentme_msg <- map["e_sentme_msg"]
        e_last_notif <- map["e_last_notif"]
        notification_settings <- map["notification_settings"]
        status <- map["status"]
        active <- map["active"]
        admin <- map["admin"]
        registered <- map["registered"]
        phone_number <- map["phone_number"]
        is_pro <- map["is_pro"]
        pro_type <- map["pro_type"]
        pro_remainder <- map["pro_remainder"]
        timezone <- map["timezone"]
        referrer <- map["referrer"]
        ref_user_id <- map["ref_user_id"]
        ref_level <- map["ref_level"]
        balance <- map["balance"]
        paypal_email <- map["paypal_email"]
        notifications_sound <- map["notifications_sound"]
        order_posts_by <- map["order_posts_by"]
        android_m_device_id <- map["android_m_device_id"]
        ios_m_device_id <- map["ios_m_device_id"]
        android_n_device_id <- map["android_n_device_id"]
        ios_n_device_id <- map["ios_n_device_id"]
        web_device_id <- map["web_device_id"]
        wallet <- map["wallet"]
        lat <- map["lat"]
        lng <- map["lng"]
        last_location_update <- map["last_location_update"]
        share_my_location <- map["share_my_location"]
        last_data_update <- map["last_data_update"]
        details <- map["details"]
        last_avatar_mod <- map["last_avatar_mod"]
        last_cover_mod <- map["last_cover_mod"]
        points <- map["points"]
        daily_points <- map["daily_points"]
        converted_points <- map["converted_points"]
        point_day_expire <- map["point_day_expire"]
        last_follow_id <- map["last_follow_id"]
        share_my_data <- map["share_my_data"]
        last_login_data <- map["last_login_data"]
        two_factor <- map["two_factor"]
        two_factor_hash <- map["two_factor_hash"]
        new_email <- map["new_email"]
        two_factor_verified <- map["two_factor_verified"]
        new_phone <- map["new_phone"]
        info_file <- map["info_file"]
        city <- map["city"]
        state <- map["state"]
        zip <- map["zip"]
        school_completed <- map["school_completed"]
        weather_unit <- map["weather_unit"]
        paystack_ref <- map["paystack_ref"]
        code_sent <- map["code_sent"]
        time_code_sent <- map["time_code_sent"]
        permission <- map["permission"]
        skills <- map["skills"]
        languages <- map["languages"]
        currently_working <- map["currently_working"]
        banned <- map["banned"]
        banned_reason <- map["banned_reason"]
        credits <- map["credits"]
        authy_id <- map["authy_id"]
        google_secret <- map["google_secret"]
        two_factor_method <- map["two_factor_method"]
        phone_privacy <- map["phone_privacy"]
        have_monetization <- map["have_monetization"]
        avatar_post_id <- map["avatar_post_id"]
        cover_post_id <- map["cover_post_id"]
        avatar_full <- map["avatar_full"]
        is_verified <- map["is_verified"]
        user_platform <- map["user_platform"]
        url <- map["url"]
        name <- map["name"]
        aPI_notification_settings <- map["API_notification_settings"]
        is_notify_stopped <- map["is_notify_stopped"]
        mutual_friends_data <- map["mutual_friends_data"]
        lastseen_unix_time <- map["lastseen_unix_time"]
        lastseen_status <- map["lastseen_status"]
        is_reported <- map["is_reported"]
        am_i_blocked <- map["am_i_blocked"]
        is_story_muted <- map["is_story_muted"]
        is_following_me <- map["is_following_me"]
        is_following <- map["is_following"]
        is_reported_user <- map["is_reported_user"]
        is_open_to_work <- map["is_open_to_work"]
        is_providing_service <- map["is_providing_service"]
        providing_service <- map["providing_service"]
        open_to_work_data <- map["open_to_work_data"]
        formated_langs <- map["formated_langs"]
    }

}

struct Reaction1 : Mappable {
    var is_reacted : Bool?
    var type : String?
    var count : Int?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        is_reacted <- map["is_reacted"]
        type <- map["type"]
        count <- map["count"]
    }

}

struct ActionResponse: Mappable {
    var api_status: Int?
    var action: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        api_status <- map["api_status"]
        action <- map["action"]
    }
}
