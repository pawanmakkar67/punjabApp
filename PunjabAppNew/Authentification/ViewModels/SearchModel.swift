/* 
Copyright (c) 2025 Swift Models Generated from JSON powered by http://www.json4swift.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

For support, please feel free to contact me at https://www.linkedin.com/in/syedabsar

*/

import Foundation
import ObjectMapper

struct SearchModel : Mappable {
	var api_status : Int?
	var all_count : Int?
	var all : [All]?
	var users : [Users]?
	var users_count : Int?
	var pages : [Pages]?
	var pages_count : Int?
	var groups : [Groups]?
	var groups_count : Int?
	var channels : [String]?

	init?(map: Map) {

	}

	mutating func mapping(map: Map) {

		api_status <- map["api_status"]
		all_count <- map["all_count"]
		all <- map["all"]
		users <- map["users"]
		users_count <- map["users_count"]
		pages <- map["pages"]
		pages_count <- map["pages_count"]
		groups <- map["groups"]
		groups_count <- map["groups_count"]
		channels <- map["channels"]
	}

}

struct All : Mappable {
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
    var avatar_post_id : Int?
    var cover_post_id : Int?
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
    var type : String?

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
        type <- map["type"]
    }

}



struct Groups : Mappable {
    var id : String?
    var user_id : String?
    var group_name : String?
    var group_title : String?
    var avatar : String?
    var cover : String?
    var about : String?
    var category : String?
    var sub_category : String?
    var privacy : String?
    var join_privacy : String?
    var active : String?
    var registered : String?
    var time : String?
    var group_id : String?
    var avatar_org : String?
    var url : String?
    var name : String?
    var category_id : String?
    var type : String?
    var username : String?
    var is_reported : Bool?
    var group_sub_category : String?
    var fields : [String]?
    var is_group_joined : Int?
    var members_count : String?
    var is_joined : String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        id <- map["id"]
        user_id <- map["user_id"]
        group_name <- map["group_name"]
        group_title <- map["group_title"]
        avatar <- map["avatar"]
        cover <- map["cover"]
        about <- map["about"]
        category <- map["category"]
        sub_category <- map["sub_category"]
        privacy <- map["privacy"]
        join_privacy <- map["join_privacy"]
        active <- map["active"]
        registered <- map["registered"]
        time <- map["time"]
        group_id <- map["group_id"]
        avatar_org <- map["avatar_org"]
        url <- map["url"]
        name <- map["name"]
        category_id <- map["category_id"]
        type <- map["type"]
        username <- map["username"]
        is_reported <- map["is_reported"]
        group_sub_category <- map["group_sub_category"]
        fields <- map["fields"]
        is_group_joined <- map["is_group_joined"]
        members_count <- map["members_count"]
        is_joined <- map["is_joined"]
    }

}

struct Pages : Mappable {
    var page_id : String?
    var user_id : String?
    var page_name : String?
    var page_title : String?
    var page_description : String?
    var avatar : String?
    var cover : String?
    var users_post : String?
    var page_category : String?
    var sub_category : String?
    var website : String?
    var facebook : String?
    var google : String?
    var vk : String?
    var twitter : String?
    var linkedin : String?
    var company : String?
    var phone : String?
    var address : String?
    var call_action_type : String?
    var call_action_type_url : String?
    var background_image : String?
    var background_image_status : String?
    var instgram : String?
    var youtube : String?
    var verified : String?
    var active : String?
    var registered : String?
    var boosted : String?
    var time : String?
    var avatar_org : String?
    var about : String?
    var id : String?
    var type : String?
    var url : String?
    var name : String?
    var rating : Int?
    var category : String?
    var page_sub_category : String?
    var is_reported : Bool?
    var is_verified : Int?
    var is_page_onwer : Bool?
    var username : String?
    var fields : [String]?
    var is_liked : String?

    init?(map: Map) {

    }

    mutating func mapping(map: Map) {

        page_id <- map["page_id"]
        user_id <- map["user_id"]
        page_name <- map["page_name"]
        page_title <- map["page_title"]
        page_description <- map["page_description"]
        avatar <- map["avatar"]
        cover <- map["cover"]
        users_post <- map["users_post"]
        page_category <- map["page_category"]
        sub_category <- map["sub_category"]
        website <- map["website"]
        facebook <- map["facebook"]
        google <- map["google"]
        vk <- map["vk"]
        twitter <- map["twitter"]
        linkedin <- map["linkedin"]
        company <- map["company"]
        phone <- map["phone"]
        address <- map["address"]
        call_action_type <- map["call_action_type"]
        call_action_type_url <- map["call_action_type_url"]
        background_image <- map["background_image"]
        background_image_status <- map["background_image_status"]
        instgram <- map["instgram"]
        youtube <- map["youtube"]
        verified <- map["verified"]
        active <- map["active"]
        registered <- map["registered"]
        boosted <- map["boosted"]
        time <- map["time"]
        avatar_org <- map["avatar_org"]
        about <- map["about"]
        id <- map["id"]
        type <- map["type"]
        url <- map["url"]
        name <- map["name"]
        rating <- map["rating"]
        category <- map["category"]
        page_sub_category <- map["page_sub_category"]
        is_reported <- map["is_reported"]
        is_verified <- map["is_verified"]
        is_page_onwer <- map["is_page_onwer"]
        username <- map["username"]
        fields <- map["fields"]
        is_liked <- map["is_liked"]
    }

}

struct Users : Mappable {
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
    var avatar_post_id : Int?
    var cover_post_id : Int?
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
