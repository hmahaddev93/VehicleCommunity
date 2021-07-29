//
//  PKUser.swift

//
//  Created by Khatib H. on 3/19/19.
//  //

import UIKit
import Firebase

class PKUser: NSObject {
    
    var uid: String?
    var username: String?
    var email: String?
    var zipCode: String?
    var gender: Int!
    var vehicleType: Int!
    var vehicleMake: String?
    var vehicleModel: String?
    var LFLP: String?
    var hashtag: String?
    var arrPhotos = [String]()
    var arrSocialLinks = [String]()
    var arrFavorites = [String]()
    var arrLikes = [PKLike]()
    var arrRideEmojiIds = [String]()
    var arrRideEmojis = [PKEmoji]()
    var arrChatIds = [String]()
    var arrBlockedUserIds = [String]()
    
    var distanceByZipCode = 0.0
    var state: String?
    var city: String?

    var zipcodeLatitude = 0.0
    var zipcodeLongitude = 0.0
    
    var fcmToken: String = ""
    var isInstagramLogin = false
    var isVerified = false

    required override init() {
    }
    
    func setUser(withDataSnapshot: DataSnapshot) {
        let value = withDataSnapshot.value as? NSDictionary
        
        print(value)
        
        uid = value?["uid"] as? String
        username = value?["username"] as? String
        email = value?["email"] as? String
        zipCode = value?["zipcode"] as? String
        gender = (value?["gender"] as! Int)
        vehicleType = (value?["v_type"] as! Int)
        vehicleMake = value?["v_make"] as? String
        vehicleModel = value?["v_model"] as? String
        LFLP = value?["LFLP"] as? String
        hashtag = value?["hashtag"] as? String
        state = value?["state"] as? String
        city = value?["city"] as? String

        let arrAllPhotos = value?["photos"] as! [String]
        
        for i in 0..<3
        {
            var strPhotoFileURL = ""
            if arrAllPhotos.indices.contains(i) {
                strPhotoFileURL = arrAllPhotos[i]
            }
            self.arrPhotos.append(strPhotoFileURL)
        }
        
        
        if ((value?["latitude"]) != nil) {
            zipcodeLatitude = value?["latitude"] as! Double
        }
        
        if ((value?["longitude"]) != nil) {
            zipcodeLongitude = value?["longitude"] as! Double
        }
        
        if ((value?["ride_emojis"]) != nil) {
            arrRideEmojiIds = value?["ride_emojis"] as! [String]
        }
        
        if ((value?["social_links"]) != nil) {
            arrSocialLinks = value?["social_links"] as! [String]
        }
        
        if ((value?["likes"]) != nil) {
            self.arrLikes.removeAll()
            let likes = (value?["likes"] as! NSDictionary).allValues
            for like in likes {
                let aLike = PKLike()
                aLike.setLike(withLikeDic:like as! [String : Any])
                self.arrLikes.append(aLike)
            }
        }
        
        if ((value?["favorites"]) != nil) {
            self.arrFavorites = (value?["favorites"] as! NSDictionary).allValues as! [String]
        }
        
        if ((value?["chats"]) != nil) {
            self.arrChatIds = (value?["chats"] as! NSDictionary).allKeys as! [String]
        }
        
        if ((value?["blocked"]) != nil) {
            self.arrBlockedUserIds = (value?["blocked"] as! NSDictionary).allValues as! [String]
        }
        
        if ((value?["fcm_token"]) != nil) {
            fcmToken = value?["fcm_token"] as! String
        }
        
        if ((value?["is_instagram_login"]) != nil) {
            isInstagramLogin = value?["is_instagram_login"] as! Bool
        }
        
        if ((value?["is_verified"]) != nil) {
            isVerified = value?["is_verified"] as! Bool
        }
    }
    
    func setUser(withUserDataDic: [String : Any]) {
        
        uid = withUserDataDic["uid"] as? String
        username = withUserDataDic["username"] as? String
        email = withUserDataDic["email"] as? String
        zipCode = withUserDataDic["zipcode"] as? String
        gender = (withUserDataDic["gender"] as! Int)
        vehicleType = (withUserDataDic["v_type"] as! Int)
        vehicleMake = withUserDataDic["v_make"] as? String
        vehicleModel = withUserDataDic["v_model"] as? String
        LFLP = withUserDataDic["LFLP"] as? String
        hashtag = withUserDataDic["hashtag"] as? String
        state = withUserDataDic["state"] as? String
        city = withUserDataDic["city"] as? String
        
        arrPhotos = withUserDataDic["photos"] as! [String]
        
        if (withUserDataDic["latitude"] != nil) {
            zipcodeLatitude = withUserDataDic["latitude"] as! Double
        }
        
        if (withUserDataDic["longitude"] != nil) {
            zipcodeLongitude = withUserDataDic["longitude"] as! Double
        }
    
        if (withUserDataDic["ride_emojis"] != nil) {
            arrRideEmojiIds = withUserDataDic["ride_emojis"] as! [String]
        }
        
        if (withUserDataDic["social_links"] != nil) {
            arrSocialLinks = withUserDataDic["social_links"] as! [String]
        }
        
        if (withUserDataDic["likes"] != nil) {
            //arrLikes = withUserDataDic["likes"] as! [String]
            
            self.arrLikes.removeAll()
            let likes = (withUserDataDic["likes"] as! NSDictionary).allValues
            for like in likes {
                let aLike = PKLike()
                aLike.setLike(withLikeDic:like as! [String : Any])
                self.arrLikes.append(aLike)
            }
            
        }
        
        if (withUserDataDic["favorites"] != nil) {
            arrFavorites = withUserDataDic["favorites"] as! [String]
        }
        
        if (withUserDataDic["blocked"] != nil) {
            arrBlockedUserIds = withUserDataDic["blocked"] as! [String]
        }
        
        if (withUserDataDic["is_instagram_login"] != nil) {
            isInstagramLogin = withUserDataDic["is_instagram_login"] as! Bool
        }
        
        if (withUserDataDic["is_verified"] != nil) {
            isVerified = withUserDataDic["is_verified"] as! Bool
        }
    }
    
    func hoursDifferenceFrom(aDate: Date) -> Int {
        let cal = Calendar.current
        let currentDate = Date()
        let components = cal.dateComponents([.hour], from: aDate, to: currentDate)
        return components.hour!
    }
    
    func isLikedUser(likedUserId:String) -> Bool
    {
        for like in self.arrLikes
        {
            if like.likerId == likedUserId && self.hoursDifferenceFrom(aDate: like.likedDate!) < 12
            {
                return true
            }
        }
        return false
    }
    
    func likeIdForUser(likedUserId:String) -> String
    {
        for like in self.arrLikes
        {
            if like.likerId == likedUserId
            {
                return like.uid!
            }
        }
        return ""
    }
    
    
    func isFavoriteUser(favUserId:String) -> Bool
    {
        for userId in self.arrFavorites
        {
            if userId == favUserId
            {
                return true
            }
        }
        return false
    }
    
    func removeFavoriteUser(favUserId:String)
    {
        var i = 0
        for userId in self.arrFavorites
        {
            if userId == favUserId
            {
                self.arrFavorites.remove(at: i)
                return
            }
            i = i + 1
        }
    }
    
    func isBlockedUser(bUserId:String) -> Bool
    {
        for userId in self.arrBlockedUserIds
        {
            if userId == bUserId
            {
                return true
            }
        }
        return false
    }
    
    func removeBlockedUser(bUserId:String)
    {
        var i = 0
        for userId in self.arrBlockedUserIds
        {
            if userId == bUserId
            {
                self.arrBlockedUserIds.remove(at: i)
                return
            }
            i = i + 1
        }
    }
    
    func removeChatId(chatId:String)
    {
        var i = 0
        for tempId in self.arrChatIds
        {
            if tempId == chatId
            {
                self.arrChatIds.remove(at: i)
                return
            }
            i = i + 1
        }
    }
    
    /*func isChatExistingWith(targetUserId: String, completion: (Bool) -> ()) {
        var isExist:Bool = false
        
        let dbRef = Database.database().reference()
        dbRef.child("chats").queryEqual(toValue: self.uid, childKey: "create_user_id").observeSingleEvent(of: .value) { (snapshot) in
            
        }
        completion(isExist)
    }*/

}
