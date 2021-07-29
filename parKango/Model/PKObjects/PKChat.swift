//
//  PKChat.swift

//
//  Created by Khatib H. on 4/19/19.
//  //

import UIKit
import Firebase

class PKChat: NSObject {
    
    var id: String?
    var createUserId: String?
    var targetUserId: String?
    var lastMessage: String? // Can be modified when a new message is entered.
    var createdTimeStamp: Int!
    var otherUser = PKUser()
    var isChecked = false
    
    required override init() {
    }
    
    func setChat(withDataSnapshot: DataSnapshot) {
        let value = withDataSnapshot.value as? NSDictionary
        
        id = withDataSnapshot.key
        createUserId = value?["create_user_id"] as? String
        targetUserId = value?["target_user_id"] as? String
        lastMessage = value?["last_message"] as? String
        createdTimeStamp = (value?["created_time_stamp"] as! Int)
    }
    
    func setChat(withChatDic: NSDictionary, andChatId: String) {
        
        id = andChatId
        createUserId = withChatDic["create_user_id"] as? String
        targetUserId = withChatDic["target_user_id"] as? String
        lastMessage = withChatDic["last_message"] as? String
        createdTimeStamp = withChatDic["created_time_stamp"] as? Int
    }

}
