//
//  PKMessage.swift

//
//  Created by Khatib H. on 4/19/19.
//  //

import UIKit
import Firebase

class PKMessage: NSObject {

    var id: String?
    var senderId: String?
    var text: String?
    var createdTimestamp: Int!
    var isReceiverRead = false
    
    required override init() {
    }
    
    func setMessage(withDataSnapshot: DataSnapshot) {
        let value = withDataSnapshot.value as? NSDictionary
        
        id = withDataSnapshot.key
        senderId = value?["sender_id"] as? String
        text = value?["text"] as? String
        createdTimestamp = (value?["created_time_stamp"] as! Int)
        
    }
}
