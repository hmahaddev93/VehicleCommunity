//
//  Constants.swift
//
//

import UIKit

let APP_NAME = "karKango"
let SCREEN_SIZE = UIScreen.main.bounds
let SCREEN_WIDTH = SCREEN_SIZE.width
let SCREEN_HEIGHT = SCREEN_SIZE.height

let SELECTED_NONE_STRING = ""
let SELECTED_NONE = -1
let SELECTED_NONE_ID = "-1"
let MAKE_FILTER_NONE = "All"

let PK_EMOJI_DESCRIPTION_MAX = 20

let MIN_PROFILE_HEIGHT = 392
struct PKGender {
    static let none = -1
    static let male = 0
    static let female = 1
    static let neutral = 2
}

struct PKVehicleType {
    static let none = -1
    static let car = 0
    static let truck = 1
    static let motorcycle = 2
    static let spectator = 3
}

struct PKEmojiType {
    static let signs = 0
    static let designs = 1
    static let engineTypes = 2
    static let energy = 3
    static let withLink = 4
    static let handTool = 5
}

struct PKProfileBrowseMode {
    static let home = 0
    static let favorites = 1
    static let filtered = 2
    static let hashtag = 3
    static let single = 4
}

struct PKSearchField {
    static let model = 0
    static let username = 1
    static let hashtag = 2
    static let lflp = 3
}

struct PKURL {
    static let termsOfService = "https://www.karkango.com/terms-of-service"
    static let privacyPolicy = "https://www.karkango.com/privacy-policy"
    static let contactUs = "https://www.karkango.com/contact-us"
}

struct ZipCodeAPI {
    static let apiKey = "NXZLYxVnDa0LOMIPJNZikwOTKG2V6mYBel5f3NoxOt0LM09yhDdr9JI9bcWCsUxa"
    static let getDistanceURLFormat = "https://www.zipcodeapi.com/rest/%@/distance.json/%@/%@/km"
    static let getLocationInfoURLFormat = "https://www.zipcodeapi.com/rest/%@/info.json/%@/degrees"
}

struct PKNotificationType {
    static let like = "like"
    static let newChat = "new_chat"
    static let deleteChat = "delete_chat"
}

struct InstagramAPI{
    
    static let INSTAGRAM_AUTH_URL_PREFIX = "https://api.instagram.com/oauth/authorize/"
    static let INSTAGRAM_USER_INFO_URL_FORMAT = "https://api.instagram.com/v1/users/self/?access_token=%@"
    static let INSTAGRAM_CLIENT_ID = "a3d0ce7f96e447b087a7545f9ec46584"
    static let INSTAGRAM_CLIENTSERCRET = "b906b1b6a37a4dfdbafbefee2e4f486b"
    static let INSTAGRAM_REDIRECT_URI = "https://karkango.com/"
    static let INSTAGRAM_SCOPE = "" /* add whatever scope you need https://www.instagram.com/developer/authorization/ */
    
}

struct PKInstagramAuthMode {
    static let login = 0
    static let verifyProfile1 = 1
    static let verifyProfile2 = 2
    static let verifyProfile3 = 3
}

struct PKAddSocialLinkMode {
    static let fromEditProfile = 0
    static let fromSignUp = 1
}

struct Constants {
    
    struct Errors {
        
    }
    
    struct Keys {
        static let firebase_fcm_api_key = "AAAAaITpsvI:APA91bHUawO2_bSguZT3HWumTIjIblRSD4OQL6dw976qT4Emw2GNhfs5gz0NwDDyG9Ffqq0xfekx4_E1dk862uVCcncdAV0e3K6hN2asrzb6NMANBZeHCIo0rj-wnUmw4_Jx_fuyzGUD"
        static let firebase_fcm_sender_id = "448906506994"
        static let twitterConsumer = ""
        static let twitterConsumerSecret = ""
    }
    
}
