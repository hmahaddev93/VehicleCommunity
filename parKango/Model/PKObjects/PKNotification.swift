//
//  PKNotification.swift

//
//  Created by Khatib H. on 4/18/19.
//  //

import UIKit
import Firebase

class PKNotification: NSObject {

    var id: String?
    var fromUserId: String?
    var fromUserName: String?
    var fromUserType: Int!
    
    var type: String?
    var msgText: String?
    
    required override init() {
    }
    
    func setNotification(withDataSnapshot: DataSnapshot) {
        let value = withDataSnapshot.value as? NSDictionary
        
        id = withDataSnapshot.key
        fromUserId = value?["from_user_id"] as? String
        fromUserName = value?["from_user_name"] as? String
        fromUserType = (value?["from_user_type"] as! Int)
        
        type = value?["type"] as? String
        msgText = value?["msg_text"] as? String
        
    }
}
